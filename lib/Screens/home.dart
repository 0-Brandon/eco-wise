import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  User? user;
  AnimationController? _fadeController;
  AnimationController? _slideController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  // Points tracking
  int currentWeekPoints = 0;
  int lastWeekPoints = 0;
  bool isLoadingPoints = true;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _loadUserPoints();
    _initializeAnimations();
  }

  Future<void> _loadUserPoints() async {
    if (user == null) {
      setState(() {
        isLoadingPoints = false;
      });
      return;
    }

    try {
      setState(() {
        isLoadingPoints = true;
      });

      // Get current week's start date (Monday)
      DateTime currentWeekStart = getCurrentWeekStart();
      DateTime lastWeekStart = getLastWeekStart();

      // Query for trash classification points this week
      final currentWeekClassifications = await FirebaseFirestore.instance
          .collection('user_activities')
          .doc(user!.uid)
          .collection('classifications')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(currentWeekStart))
          .get();

      // Query for lesson completion points this week
      final currentWeekLessons = await FirebaseFirestore.instance
          .collection('user_activities')
          .doc(user!.uid)
          .collection('lessons_completed')
          .where('completed_at', isGreaterThanOrEqualTo: Timestamp.fromDate(currentWeekStart))
          .get();

      // Query for last week's activities
      final lastWeekClassifications = await FirebaseFirestore.instance
          .collection('user_activities')
          .doc(user!.uid)
          .collection('classifications')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeekStart))
          .where('timestamp', isLessThan: Timestamp.fromDate(currentWeekStart))
          .get();

      final lastWeekLessons = await FirebaseFirestore.instance
          .collection('user_activities')
          .doc(user!.uid)
          .collection('lessons_completed')
          .where('completed_at', isGreaterThanOrEqualTo: Timestamp.fromDate(lastWeekStart))
          .where('completed_at', isLessThan: Timestamp.fromDate(currentWeekStart))
          .get();

      // Calculate current week points
      int currentPoints = 0;

      // Points from trash classifications (10 points per correct, 2 for attempt)
      for (var doc in currentWeekClassifications.docs) {
        bool isCorrect = doc.data()['is_correct'] as bool? ?? false;
        if (isCorrect) {
          currentPoints += 10;
        } else {
          currentPoints += 2;
        }
      }

      // Points from completed lessons (25 points per lesson)
      for (var _ in currentWeekLessons.docs) {
        currentPoints += 25;
      }

      // Calculate last week points
      int lastPoints = 0;

      for (var doc in lastWeekClassifications.docs) {
        bool isCorrect = doc.data()['is_correct'] as bool? ?? false;
        if (isCorrect) {
          lastPoints += 10;
        } else {
          lastPoints += 2;
        }
      }

      for (var _ in lastWeekLessons.docs) {
        lastPoints += 25;
      }

      setState(() {
        currentWeekPoints = currentPoints;
        lastWeekPoints = lastPoints;
        isLoadingPoints = false;
      });
    } catch (e) {
      print('Error loading points: $e');
      setState(() {
        currentWeekPoints = 0;
        lastWeekPoints = 0;
        isLoadingPoints = false;
      });
    }
  }

  DateTime getCurrentWeekStart() {
    DateTime now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  DateTime getLastWeekStart() {
    return getCurrentWeekStart().subtract(const Duration(days: 7));
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController!, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController!, curve: Curves.easeOutCubic));

    _fadeController!.forward();
    _slideController!.forward();
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: FadeTransition(
              opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
              child: SlideTransition(
                position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 32),
                    _buildStatsCard(theme),
                    const SizedBox(height: 32),
                    _buildQuickActions(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final userName = user?.email?.split('@').first ?? '[USER]';
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: theme.textTheme.displayLarge,
        ),
      ],
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    double percentageChange = lastWeekPoints > 0
        ? ((currentWeekPoints - lastWeekPoints) / lastWeekPoints * 100)
        : 0.0;
    bool isPositive = percentageChange >= 0;
    String changeText = '${isPositive ? '+' : '-'}${percentageChange.toStringAsFixed(0)}%';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.eco,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Week',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (isLoadingPoints)
                              Container(
                                width: 60,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Text(
                                currentWeekPoints.toString(),
                                style: theme.textTheme.displayMedium,
                              ),
                            const SizedBox(width: 8),
                            if (!isLoadingPoints && lastWeekPoints > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (isPositive
                                      ? theme.colorScheme.secondaryContainer
                                      : Colors.red.shade100
                                  ).withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPositive ? Icons.trending_up : Icons.trending_down,
                                      size: 12,
                                      color: isPositive
                                          ? theme.colorScheme.primary
                                          : Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      changeText,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isPositive
                                            ? theme.colorScheme.primary
                                            : Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Eco Points Earned',
                    style: theme.textTheme.titleMedium,
                  ),
                  if (isLoadingPoints)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _loadUserPoints,
                      child: Icon(
                        Icons.refresh,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _buildActionCard(
              theme,
              Icons.camera_alt_rounded,
              'Classify Trash',
              'Earn 10 points',
              '/classify',
              theme.colorScheme.secondary,
            ),
            _buildActionCard(
              theme,
              Icons.menu_book_rounded,
              'Learn',
              'Earn 25 points',
              '/lessons',
              theme.colorScheme.primary,
            ),
            _buildActionCard(
              theme,
              Icons.leaderboard_rounded,
              'Leaderboard',
              'Your ranking',
              '/leaderboard',
              theme.colorScheme.primary,
            ),
            _buildActionCard(
              theme,
              Icons.person_rounded,
              'Profile',
              'Your stats',
              '/profile',
              theme.colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      ThemeData theme,
      IconData icon,
      String title,
      String subtitle,
      String route,
      Color accentColor,
      ) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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


      /*
      user_activities/{userId}/
      ├── classifications/
      │   ├── {docId}
      │   │   ├── timestamp: Timestamp
      │   │   ├── is_correct: boolean
      │   │   ├── trash_type: string
      │   │   └── confidence_score: number
      └── lessons_completed/
          ├── {docId}
          │   ├── completed_at: Timestamp
          │   ├── lesson_id: string
          │   └── score: number
      */
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

      // Points from trash classifications (e.g., 10 points per correct classification)
      for (var doc in currentWeekClassifications.docs) {
        bool isCorrect = doc.data()['is_correct'] as bool? ?? false;
        if (isCorrect) {
          currentPoints += 10; // 10 points per correct classification
        } else {
          currentPoints += 2; // 2 points for attempting, even if wrong
        }
      }

      // Points from completed lessons (e.g., 25 points per lesson)
      for (var _ in currentWeekLessons.docs) {
        currentPoints += 25; // 25 points per completed lesson
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
      // Handle errors gracefully
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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity, //Why needed here but not in login and signup?
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFd9f7e5), Color(0xFFb2f2bb)],
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
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildStatsCard(),
                    const SizedBox(height: 32),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userName = user?.email?.split('@').first ?? '[USER]';
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            fontFamily: 'Roboto',
            color: Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          userName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: Color(0xFF2e7d32),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
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
            color: const Color(0xFF2e7d32).withValues(alpha: 0.1),
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
                      color: const Color(0xFF4db6ac).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF2e7d32),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (isLoadingPoints)
                              Container(
                                width: 60,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF81c784).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2e7d32)),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Text(
                                currentWeekPoints.toString(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2e7d32),
                                  fontFamily: 'Roboto',
                                ),
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
                                      ? const Color(0xFF81c784)
                                      : const Color(0xFFe57373)
                                  ).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isPositive ? Icons.trending_up : Icons.trending_down,
                                      size: 12,
                                      color: isPositive
                                          ? const Color(0xFF2e7d32)
                                          : const Color(0xFFc62828),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      changeText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isPositive
                                            ? const Color(0xFF2e7d32)
                                            : const Color(0xFFc62828),
                                        fontFamily: 'Roboto',
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
                  const Text(
                    'Eco Points Earned',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF212121),
                      fontFamily: 'Roboto',
                    ),
                  ),
                  if (isLoadingPoints)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2e7d32)),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _loadUserPoints,
                      child: const Icon(
                        Icons.refresh,
                        color: Color(0xFF757575),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
            color: Color(0xFF2e7d32),
          ),
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
              Icons.camera_alt_rounded,
              'Classify Trash',
              'Earn 10 points',
              '/classify',
              const Color(0xFF4db6ac),
            ),
            _buildActionCard(
              Icons.menu_book_rounded,
              'Learn',
              'Earn 25 points',
              '/lessons',
              const Color(0xFF81c784),
            ),
            _buildActionCard(
              Icons.leaderboard_rounded,
              'Leaderboard',
              'Your ranking',
              '/leaderboard',
              const Color(0xFF2e7d32),
            ),
            _buildActionCard(
              Icons.person_rounded,
              'Profile',
              'Your stats',
              '/profile',
              const Color(0xFF4db6ac),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    fontFamily: 'Roboto',
                  ),
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
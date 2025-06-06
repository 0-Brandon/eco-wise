import 'dart:ui';
import 'package:eco_wise/Models/users.dart';
import 'package:eco_wise/Providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final UserModel? currentUser = ref.watch(userProvider);

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
              opacity: const AlwaysStoppedAnimation(1.0),
              child: SlideTransition(
                position: const AlwaysStoppedAnimation(Offset.zero),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 32),
                    _buildProfileCard(theme, currentUser),
                    const SizedBox(height: 24),
                    _buildStatsCard(theme, currentUser),
                    const SizedBox(height: 24),
                   // _buildAchievementsCard(theme, currentUser),
                    const SizedBox(height: 24),
                   // _buildFriendsCard(theme, currentUser),
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
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'Profile',
          style: theme.textTheme.headlineLarge,
        ),
      ],
    );
  }

  Widget _buildProfileCard(ThemeData theme, UserModel? user) {
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
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    backgroundImage: user?.imageURL.isNotEmpty == true
                        ? NetworkImage(user!.imageURL)
                        : null,
                    child: user?.imageURL.isEmpty != false
                        ? Icon(
                      Icons.person,
                      size: 50,
                      color: theme.colorScheme.onSecondaryContainer,
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: theme.colorScheme.onSecondary,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'User Name',
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'user@example.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildStatsCard(ThemeData theme, UserModel? user) {
    final int totalLessons = user?.lessons?.length ?? 0;
    final int totalFriends = user?.lessons?.length ?? 0;
    final int ecoPoints = user?.ecopoints ?? 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
            padding:const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:Colors.white.withValues(alpha:0.3),
              width: 1,
            ),
          ),
          child:Column (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children:[
                  Icon(
                    Icons.analytics_rounded,
                    color:theme.colorScheme.primary,
                    size:24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Your Stats',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height:20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(theme, ecoPoints.toString(), 'Ecopoints', Icons.eco),
                  _buildStatItem(theme, totalLessons.toString(), 'Lessons', Icons.school),
                  _buildStatItem(theme, totalFriends.toString(), 'Friends', Icons.people),
                ]
              )
            ]
          )
        )
      )
    );
  }
  Widget _buildStatItem(ThemeData theme, String value, String label, IconData icon){
    return Column(
      children: [
        Container(
          padding:const EdgeInsets.all(12),
          decoration:BoxDecoration(
            color:theme.colorScheme.secondaryContainer.withValues(alpha:0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child:Icon(
            icon,
            color: theme.colorScheme.primary,
            size:24,
          ),
        ),
        const SizedBox(height:8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight:FontWeight.bold,
          ),
        ),
        const SizedBox(height:4),
        Text(
          label,
          style:theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
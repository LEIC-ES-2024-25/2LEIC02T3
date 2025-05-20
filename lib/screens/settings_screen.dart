import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../services/auth_service.dart';
import '../widgets/auth_wrapper.dart';   // ← import AuthWrapper
import 'bottom_navigation_bar.dart';
import '../providers/badges_provider.dart';
import '../providers/points_provider.dart';
import '../providers/challenges_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get AuthService from Provider
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              // 1. Clear local progress for all providers
              await Provider.of<BadgesProvider>(context, listen: false).clearLocalProgress();
              await Provider.of<PointsProvider>(context, listen: false).clearLocalPoints();
              await Provider.of<ChallengesProvider>(context, listen: false).clearLocalChallengeProgress();
              // 2. Sign out the user
              await authService.signOut();
              // 3. Clear any pending SnackBars/notifications
              ScaffoldMessenger.of(context).clearSnackBars();
              // 4. Navigate back to AuthWrapper (login/register)
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('User Settings Area'),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'SettingsScreen',
      ),
    );
  }
}
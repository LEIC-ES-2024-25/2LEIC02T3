import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../services/auth_service.dart';
import '../widgets/auth_wrapper.dart';   // ← import AuthWrapper
import 'bottom_navigation_bar.dart';

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
              // 1. Sign out the user
              await authService.signOut();

              // 2. Clear any pending SnackBars/notifications
              ScaffoldMessenger.of(context).clearSnackBars();

              // 3. Navigate back to AuthWrapper (login/register)
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
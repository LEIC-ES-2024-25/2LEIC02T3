import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/badges_provider.dart';
import '../providers/challenges_provider.dart';
import '../providers/points_provider.dart';
import '../services/auth_service.dart';
import '../services/progress_service.dart';
import '../widgets/auth_wrapper.dart';
import 'bottom_navigation_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;
  bool _notificationsEnabled = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
  }
  
  Future<void> _loadNotificationPreference() async {
    try {
      final progressService = ProgressService();
      final userData = await progressService.getUserProgress();
      if (userData != null && userData.containsKey('notifications_enabled')) {
        setState(() {
          _notificationsEnabled = userData['notifications_enabled'] as bool;
        });
      }
    } catch (e) {
      debugPrint('Error loading notification preference: $e');
    }
  }
  
  Future<void> _saveNotificationPreference(bool enabled) async {
    try {
      await ProgressService().setUserProgress({
        'notifications_enabled': enabled,
      });
    } catch (e) {
      debugPrint('Error saving notification preference: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving notification settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);

      await Provider.of<BadgesProvider>(context, listen: false).clearLocalProgress();
      await Provider.of<PointsProvider>(context, listen: false).clearLocalPoints();
      await Provider.of<ChallengesProvider>(context, listen: false).clearLocalChallengeProgress();

      await authService.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
              (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _isLoading ? null : () => _handleLogout(context),
          ),
        ],
      ),
      backgroundColor: Colors.green.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader('Account'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListTile(
                  leading: const Icon(Icons.account_circle, color: Colors.green),
                  title: const Text('My Profile'),
                  subtitle: Text(
                    Provider.of<AuthService>(context).currentUser?.email ?? 'Not logged in',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionHeader('Preferences'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SwitchListTile(
                  title: const Text('Notifications'),
                  subtitle: const Text('Receive alerts about challenges'),
                  secondary: Icon(
                      _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                      color: Colors.green
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    await _saveNotificationPreference(value);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(value ? 'Notifications enabled' : 'Notifications disabled'),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionHeader('About'),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.share, color: Colors.green),
                      title: const Text('Share App'),
                      onTap: () async {
                        final uri = Uri.parse('https://github.com/LuisF775/ESOF_APP');
                        try {
                          final success = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication
                          );
                          if (!success && mounted) {
                            throw 'Could not open $uri';
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: Colors.green),
                      title: const Text('App Version'),
                      subtitle: const Text('1.0.0'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'SettingsScreen',
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}
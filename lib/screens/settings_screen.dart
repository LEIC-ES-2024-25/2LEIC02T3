import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/auth_wrapper.dart';
import 'bottom_navigation_bar.dart';
import '../providers/badges_provider.dart';
import '../providers/points_provider.dart';
import '../providers/challenges_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();
  String? _message;

  Future<void> _changePassword() async {
    try {
      await FirebaseAuth.instance.currentUser!
          .updatePassword(_passwordController.text.trim());
      setState(() => _message = "Password updated successfully.");
    } on FirebaseAuthException catch (e) {
      setState(() => _message = e.message ?? "Failed to update password.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await Provider.of<BadgesProvider>(context, listen: false).clearLocalProgress();
              await Provider.of<PointsProvider>(context, listen: false).clearLocalPoints();
              await Provider.of<ChallengesProvider>(context, listen: false).clearLocalChallengeProgress();
              await authService.signOut();
              ScaffoldMessenger.of(context).clearSnackBars();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthWrapper()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Share App'),
              onPressed: () async {
                final uri = Uri.parse('https://github.com/LuisF775/ESOF_APP');
                try {
                  final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
                  if (!success) {
                    throw 'Could not launch $uri';
                  }
                } catch (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open URL')),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Change Password',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Update Password'),
                      onPressed: _changePassword,
                    ),
                    if (_message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _message!,
                          style: TextStyle(
                            color: _message!.toLowerCase().contains("success")
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const Expanded(
              child: Center(child: Text('User Settings Area')),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'SettingsScreen',
      ),
    );
  }
}

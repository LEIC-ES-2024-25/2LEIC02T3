import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('This is the Settings Screen'),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'SettingsScreen',
      ),
    );
  }
}
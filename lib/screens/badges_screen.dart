import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Badges'),
      ),
      body: const Center(
        child: Text('This is the Badges Screen'),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'BadgesScreen',
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'screens/challenges_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco-Friendly Challenges',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ChallengesScreen(), // Set ChallengesScreen as the home screen
    );
  }
}
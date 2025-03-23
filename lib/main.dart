import 'package:flutter/material.dart';
import 'screens/shop_screen.dart'; // Import your screens
import 'screens/badges_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/qrcode_generator_screen.dart';
import 'screens/settings_screen.dart';

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
      //home: const ChallengesScreen(), // Set ChallengesScreen as the home screen
      initialRoute: '/challenges', // Set the initial route
      routes: {
        '/shop': (context) => const ShopScreen(),
        '/badges': (context) => const BadgesScreen(),
        '/challenges': (context) => const ChallengesScreen(),
        '/qrcode-generator': (context) => const QRcodeGeneratorScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/shop_screen.dart';
import 'screens/badges_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/qrcode_generator_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/points_provider.dart';
import 'providers/badges_provider.dart';
import 'providers/challenges_provider.dart';

void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PointsProvider()),
        ChangeNotifierProvider(create: (_) => BadgesProvider()),
        ChangeNotifierProvider(create: (_) => ChallengesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eco-Friendly Challenges',
      theme: ThemeData(
        primaryColor: Colors.green, // Set the primary color to green
        colorScheme: ColorScheme.light(
          primary: Colors.green, // Use green as the primary color
          secondary: Colors.green, // Use green as the secondary/accent color
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green), // Match the focus border color
          ),
        ),
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
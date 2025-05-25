import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'screens/shop_screen.dart';
import 'screens/badges_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/qrcode_generator_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/points_provider.dart';
import 'providers/badges_provider.dart';
import 'providers/challenges_provider.dart';
import 'services/auth_service.dart'; 
import 'widgets/auth_wrapper.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()), 
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
        primaryColor: Colors.green, 
        colorScheme: ColorScheme.light(
          primary: Colors.green, 
          secondary: Colors.green, 
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.green), 
          ),
        ),
      ),
      home: const AuthWrapper(),
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
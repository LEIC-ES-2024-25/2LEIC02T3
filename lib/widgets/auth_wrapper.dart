import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart'; 
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/challenges_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLoginScreen = true;

  void _toggleScreens() {
    setState(() {
      _showLoginScreen = !_showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.authStateChanges, 
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null) {
            
            return const ChallengesScreen(); 
          }
          
          if (_showLoginScreen) {
            return LoginScreen(showRegisterScreen: _toggleScreens);
          } else {
            return RegisterScreen(showLoginScreen: _toggleScreens);
          }
        }
        
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
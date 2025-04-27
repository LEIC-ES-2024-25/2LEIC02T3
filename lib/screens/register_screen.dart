import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuthException
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback showLoginScreen;
  const RegisterScreen({super.key, required this.showLoginScreen});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // Add confirm password
  final AuthService _authService = AuthService();
  String? _errorMessage;
  bool _isLoading = false; // Add loading state

  Future<void> _signUp() async {
    // Check if passwords match
    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      setState(() {
        _errorMessage = "Passwords do not match.";
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true; // Start loading
    });

    try {
      final result = await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // AuthWrapper handles navigation on success, no need to check result here
      // if (result == null) { // This check is handled by the catch block now
      //   // Generic error if specific exception wasn't caught (shouldn't happen often)
      //   setState(() { _errorMessage = "Sign up failed. Please try again."; });
      // }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        default:
          message = 'An unknown error occurred. Please try again.';
          print('Sign up failed with code: ${e.code}, message: ${e.message}'); // Log unknown errors
      }
      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      // Catch any other unexpected errors
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
      print('Unexpected sign up error: $e');
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Dispose the new controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center( // Center the content
          child: SingleChildScrollView( // Allow scrolling on smaller screens
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email), // Add icon
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock), // Add icon
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField( // Add confirm password field
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline), // Add icon
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (_isLoading) // Show loading indicator
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom( // Add some style
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: const Text('Sign Up'),
                  ),
                TextButton(
                  onPressed: _isLoading ? null : widget.showLoginScreen, // Disable during loading
                  child: const Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
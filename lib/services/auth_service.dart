import 'package:firebase_auth/firebase_auth.dart';
import '../services/progress_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  
  User? get currentUser => _auth.currentUser;

  
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      
      print('Sign in failed: ${e.message}');
      return null;
    }
  }

  
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      if (credential.user != null) {
        await ProgressService().setUserProgress({
          'badges': [], 
          'notifications_enabled': true  
        });
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      
      print('Sign up failed: ${e.message}');
      return null;
    }
  }

  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
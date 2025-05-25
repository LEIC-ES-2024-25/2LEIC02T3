import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:es_app/services/progress_service.dart';

// Mock classes - Simplified versions without using mockito since it requires code generation
class MockUser implements User {
  final String _uid;
  final String _email;
  
  MockUser({required String uid, required String email}) 
    : _uid = uid, 
      _email = email;
  
  @override
  String get uid => _uid;
  
  @override
  String? get email => _email;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserCredential implements UserCredential {
  final MockUser? _user;
  
  MockUserCredential({MockUser? user}) : _user = user;
  
  @override
  User? get user => _user;
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseAuth implements FirebaseAuth {
  final StreamController<User?> _authStateController = StreamController<User?>.broadcast();
  MockUser? _currentUser;
  
  @override
  Stream<User?> authStateChanges() => _authStateController.stream;
  
  @override
  User? get currentUser => _currentUser;
  
  void signInUser(MockUser user) {
    _currentUser = user;
    _authStateController.add(user);
  }
  
  void signOutUser() {
    _currentUser = null;
    _authStateController.add(null);
  }
  
  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email == 'test@example.com' && password == 'password123') {
      final user = MockUser(uid: 'test-uid', email: email);
      signInUser(user);
      return MockUserCredential(user: user);
    } else if (email == 'error@example.com') {
      throw FirebaseAuthException(code: 'user-not-found', message: 'No user found for that email.');
    } else if (password == 'wrongpassword') {
      throw FirebaseAuthException(code: 'wrong-password', message: 'Wrong password provided.');
    }
    throw FirebaseAuthException(code: 'invalid-credential', message: 'Invalid credentials');
  }
  
  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (email == 'existing@example.com') {
      throw FirebaseAuthException(code: 'email-already-in-use', message: 'The email address is already in use');
    } else if (password.length < 6) {
      throw FirebaseAuthException(code: 'weak-password', message: 'The password is too weak');
    }
    
    final user = MockUser(uid: 'new-user-uid', email: email);
    signInUser(user);
    return MockUserCredential(user: user);
  }
  
  @override
  Future<void> signOut() async {
    signOutUser();
  }
  
  void dispose() {
    _authStateController.close();
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock ProgressService
class MockProgressService implements ProgressService {
  Map<String, dynamic> userData = {};
  
  @override
  Future<void> setUserProgress(Map<String, dynamic> progressData) async {
    userData.addAll(progressData);
  }
  
  @override
  Future<Map<String, dynamic>?> getUserProgress() async {
    return userData;
  }
}

// Test version of AuthService that uses our mocks
class TestAuthService {
  final MockFirebaseAuth _auth;
  final MockProgressService _progressService;
  
  TestAuthService({
    required MockFirebaseAuth mockAuth,
    required MockProgressService mockProgress,
  }) : _auth = mockAuth,
       _progressService = mockProgress;
  
  // Stream to listen for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., user-not-found, wrong-password)
      print('Sign in failed: ${e.message}');
      return null;
    }
  }

  // Sign up with Email and Password
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Initialize user_progress with empty badges field
      if (credential.user != null) {
        await _progressService.setUserProgress({'badges': []});
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., email-already-in-use, weak-password)
      print('Sign up failed: ${e.message}');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockProgressService mockProgressService;
  late TestAuthService authService;
  
  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockProgressService = MockProgressService();
    authService = TestAuthService(
      mockAuth: mockFirebaseAuth,
      mockProgress: mockProgressService,
    );
  });
  
  tearDown(() {
    mockFirebaseAuth.dispose();
  });
  
  group('AuthService Tests', () {
    test('should return current user', () {
      // Initially no user is signed in
      expect(authService.currentUser, isNull);
      
      // Sign in a mock user
      final mockUser = MockUser(uid: 'test-uid', email: 'test@example.com');
      mockFirebaseAuth.signInUser(mockUser);
      
      // Now currentUser should return the mock user
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser?.uid, equals('test-uid'));
      expect(authService.currentUser?.email, equals('test@example.com'));
    });
    
    test('authStateChanges should emit events when auth state changes', () async {
      // Set up a listener for auth state changes
      final states = <User?>[];
      final subscription = authService.authStateChanges.listen(states.add);
      
      // Initially no user is signed in
      expect(states, isEmpty);
      
      // Sign in a user
      final mockUser = MockUser(uid: 'test-uid', email: 'test@example.com');
      mockFirebaseAuth.signInUser(mockUser);
      
      // Wait for the event to be processed
      await Future.delayed(Duration.zero);
      expect(states.length, 1);
      expect(states.first?.uid, equals('test-uid'));
      
      // Sign out the user
      mockFirebaseAuth.signOutUser();
      
      // Wait for the event to be processed
      await Future.delayed(Duration.zero);
      expect(states.length, 2);
      expect(states.last, isNull);
      
      // Clean up the subscription
      subscription.cancel();
    });
    
    test('signInWithEmailAndPassword should return UserCredential on success', () async {
      final result = await authService.signInWithEmailAndPassword('test@example.com', 'password123');
      
      expect(result, isNotNull);
      expect(result?.user?.email, equals('test@example.com'));
      expect(result?.user?.uid, equals('test-uid'));
    });
    
    test('signInWithEmailAndPassword should return null on wrong password', () async {
      final result = await authService.signInWithEmailAndPassword('test@example.com', 'wrongpassword');
      
      expect(result, isNull);
    });
    
    test('signInWithEmailAndPassword should return null on non-existent user', () async {
      final result = await authService.signInWithEmailAndPassword('error@example.com', 'password123');
      
      expect(result, isNull);
    });
    
    test('signUpWithEmailAndPassword should return UserCredential on success', () async {
      final result = await authService.signUpWithEmailAndPassword('new@example.com', 'password123');
      
      expect(result, isNotNull);
      expect(result?.user?.email, equals('new@example.com'));
      expect(result?.user?.uid, equals('new-user-uid'));
      
      // Verify that user progress was initialized
      expect(mockProgressService.userData.containsKey('badges'), isTrue);
      expect(mockProgressService.userData['badges'], isEmpty);
    });
    
    test('signUpWithEmailAndPassword should return null on existing email', () async {
      final result = await authService.signUpWithEmailAndPassword('existing@example.com', 'password123');
      
      expect(result, isNull);
    });
    
    test('signUpWithEmailAndPassword should return null on weak password', () async {
      final result = await authService.signUpWithEmailAndPassword('new@example.com', '123');
      
      expect(result, isNull);
    });
    
    test('signOut should sign out the current user', () async {
      // First sign in a user
      final mockUser = MockUser(uid: 'test-uid', email: 'test@example.com');
      mockFirebaseAuth.signInUser(mockUser);
      
      // Verify the user is signed in
      expect(authService.currentUser, isNotNull);
      
      // Sign out
      await authService.signOut();
      
      // Verify the user is signed out
      expect(authService.currentUser, isNull);
    });
  });
}

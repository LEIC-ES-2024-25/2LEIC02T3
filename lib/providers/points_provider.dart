import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/progress_service.dart';

class PointsProvider with ChangeNotifier {
  int _points = 0;
  late final StreamSubscription<User?> _authSubscription;

  PointsProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadPoints();
      } else {
        clearLocalPoints();
      }
    });
    _loadPoints();
  }
  
  int get points => _points;
  
  Future<void> _loadPoints() async {
    try {
      final firestoreData = await ProgressService().getUserProgress();
      if (firestoreData != null && firestoreData.containsKey('points')) {
        _points = firestoreData['points'] as int;
      } else {
        _points = 0; // Default to 0 if no data in Firestore or key missing
      }
    } catch (e) {
      debugPrint('Failed to load points from Firestore: $e. Initializing with 0 points.');
      _points = 0;
    }
    notifyListeners();
  }
  
  Future<void> addPoints(int points) async {
    _points += points;
    
    // --- Firestore progress tracking ---
    try {
      await ProgressService().setUserProgress({
        'points': _points,
      });
    } catch (e) {
      debugPrint('Failed to update points in Firestore: $e');
    }
    // --- End Firestore progress tracking ---
    
    notifyListeners();
  }
  
  Future<void> removePoints(int points) async {
    _points -= points;
    if (_points < 0) {
      _points = 0;
    }
    
    // --- Firestore progress tracking ---
    try {
      await ProgressService().setUserProgress({
        'points': _points,
      });
    } catch (e) {
      debugPrint('Failed to update points in Firestore: $e');
    }
    // --- End Firestore progress tracking ---
    
    notifyListeners();
  }

  Future<void> clearLocalPoints() async {
    _points = 0; // Reset in-memory points to 0
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
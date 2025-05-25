import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/badge.dart';
import '../data/badge_data.dart';
import 'points_provider.dart';
import '../services/progress_service.dart';

class BadgesProvider with ChangeNotifier {
  List<Badge_> _badges = [];
  late final StreamSubscription<User?> _authSubscription;
  final BadgeService _badgeService = BadgeService();
  
  BadgesProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        _loadBadgesFromFirestore();
      } else {
        clearLocalProgress();
      }
    });
    _loadBadges();
  }
  
  List<Badge_> get badges => _badges;
  
  Future<void> _loadBadges() async {
    _badges = _badgeService.getAllBadges(); 
    try {
      final firestoreData = await ProgressService().getUserProgress();
      if (firestoreData != null && firestoreData['badges'] is List) {
        final unlockedIds = List<String>.from(firestoreData['badges']);
        for (var badge in _badges) {
          badge.isUnlocked = unlockedIds.contains(badge.id);
        }
      } else {
        
        for (var badge in _badges) {
          badge.isUnlocked = false;
        }
      }
    } catch (e) {
      debugPrint('Failed to load badges from Firestore: $e. Initializing with all badges locked.');
      for (var badge in _badges) {
        badge.isUnlocked = false;
      }
    }
    notifyListeners();
  }
  
  Future<void> unlockBadge(String badgeId, [BuildContext? context]) async {
    final badgeIndex = _badges.indexWhere((badge) => badge.id == badgeId);
    if (badgeIndex != -1 && !_badges[badgeIndex].isUnlocked) {
      final badge = _badges[badgeIndex];
      badge.isUnlocked = true;
      
      
      if (context != null) {
        final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
        await pointsProvider.addPoints(badge.pointsToGain);
        
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Badge unlocked: ${badge.name} (+${badge.pointsToGain} points)'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      
      try {
        final unlockedBadges = _badges.where((b) => b.isUnlocked).map((b) => b.id).toList();
        await ProgressService().setUserProgress({
          'badges': unlockedBadges,
        });
      } catch (e) {
        debugPrint('Failed to update badges in Firestore: $e');
      }
      
      
      notifyListeners();
    }
  }
  
  
  Future<void> unlockBadgeWithPoints(String badgeId, PointsProvider pointsProvider) async {
    final badgeIndex = _badges.indexWhere((badge) => badge.id == badgeId);
    if (badgeIndex != -1 && !_badges[badgeIndex].isUnlocked) {
      final badge = _badges[badgeIndex];
      badge.isUnlocked = true;
      
      
      await pointsProvider.addPoints(badge.pointsToGain);

      
      try {
        final unlockedBadges = _badges.where((b) => b.isUnlocked).map((b) => b.id).toList();
        await ProgressService().setUserProgress({
          'badges': unlockedBadges,
        });
      } catch (e) {
        debugPrint('Failed to update badges in Firestore: $e');
      }
      
      
      notifyListeners();
    }
  }
  
  Badge_? getBadgeById(String id) {
    try {
      return _badges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }
  
  int get unlockedBadgesCount => _badges.where((badge) => badge.isUnlocked).length;
  
  int get totalBadgesCount => _badges.length;

  Future<void> clearLocalProgress() async {
    
    _badges = _badgeService.getAllBadges(); 
    
    
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadBadgesFromFirestore() async {
    _badges = _badgeService.getAllBadges();
    try {
      final firestoreData = await ProgressService().getUserProgress();
      if (firestoreData != null && firestoreData['badges'] is List) {
        final unlockedIds = List<String>.from(firestoreData['badges']);
        for (var badge in _badges) {
          badge.isUnlocked = unlockedIds.contains(badge.id);
        }
      }
    } catch (_) {}
    notifyListeners();
  }
}
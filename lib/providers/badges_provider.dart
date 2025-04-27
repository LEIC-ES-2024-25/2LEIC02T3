import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/badge.dart';
import '../data/badge_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'points_provider.dart';

class BadgesProvider with ChangeNotifier {
  List<Badge_> _badges = [];
  final BadgeService _badgeService = BadgeService();
  
  BadgesProvider() {
    _loadBadges();
  }
  
  List<Badge_> get badges => _badges;
  
  Future<void> _loadBadges() async {
    // Get all badges from service
    _badges = _badgeService.getAllBadges();
    
    // Load unlocked status from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    for (var badge in _badges) {
      final isUnlocked = prefs.getBool('badge_${badge.id}') ?? badge.isUnlocked;
      badge.isUnlocked = isUnlocked;
    }
    notifyListeners();
  }
  
  Future<void> unlockBadge(String badgeId, [BuildContext? context]) async {
    final badgeIndex = _badges.indexWhere((badge) => badge.id == badgeId);
    if (badgeIndex != -1 && !_badges[badgeIndex].isUnlocked) {
      final badge = _badges[badgeIndex];
      badge.isUnlocked = true;
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('badge_${badgeId}', true);
      
      // Add points if context is provided
      if (context != null) {
        final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
        await pointsProvider.addPoints(badge.pointsToGain);
        
        // Show a notification that badge was unlocked with points
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Badge unlocked: ${badge.name} (+${badge.pointsToGain} points)'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      notifyListeners();
    }
  }
  
  // Overload unlockBadge to work with provider directly
  Future<void> unlockBadgeWithPoints(String badgeId, PointsProvider pointsProvider) async {
    final badgeIndex = _badges.indexWhere((badge) => badge.id == badgeId);
    if (badgeIndex != -1 && !_badges[badgeIndex].isUnlocked) {
      final badge = _badges[badgeIndex];
      badge.isUnlocked = true;
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('badge_${badgeId}', true);
      
      // Add points directly using the provided points provider
      await pointsProvider.addPoints(badge.pointsToGain);
      
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
}
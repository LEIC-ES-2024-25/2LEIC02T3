import 'package:flutter/foundation.dart';
import '../models/badge.dart';
import '../services/badge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  Future<void> unlockBadge(String badgeId) async {
    final badgeIndex = _badges.indexWhere((badge) => badge.id == badgeId);
    if (badgeIndex != -1 && !_badges[badgeIndex].isUnlocked) {
      _badges[badgeIndex].isUnlocked = true;
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('badge_${badgeId}', true);
      
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
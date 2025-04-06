import 'package:flutter/material.dart' hide Badge;
import '../models/badge.dart';

class BadgeService {
  // In a real app, this would come from a database or API
  List<Badge_> getAllBadges() {
    return [
      Badge_(
        id: 'eco_beginner',
        name: 'Eco Beginner',
        description: 'Complete your first eco challenge',
        icon: Icons.eco,
        pointsToUnlock: 10,
      ),
      Badge_(
        id: 'step_enthusiast',
        name: 'Step Enthusiast',
        description: 'Walk 10,000 steps in one day',
        icon: Icons.directions_walk,
        pointsToUnlock: 50,
      ),
      Badge_(
        id: 'water_saver',
        name: 'Water Saver',
        description: 'Complete 5 shower time challenges',
        icon: Icons.water_drop,
        pointsToUnlock: 75,
      ),
      Badge_(
        id: 'screen_balancer',
        name: 'Screen Balancer',
        description: 'Keep your screen time under 2 hours for a week',
        icon: Icons.phone_android,
        pointsToUnlock: 100,
      ),
      Badge_(
        id: 'cycling_pro',
        name: 'Cycling Pro',
        description: 'Use a bicycle instead of a car 10 times',
        icon: Icons.directions_bike,
        pointsToUnlock: 150,
      ),
      Badge_(
        id: 'community_leader',
        name: 'Community Leader',
        description: 'Organize an eco-friendly event',
        icon: Icons.people,
        pointsToUnlock: 200,
      ),
      Badge_(
        id: 'eco_master',
        name: 'Eco Master',
        description: 'Complete all other badges',
        icon: Icons.military_tech,
        isUnlocked: false,
        pointsToUnlock: 500,
      ),
    ];
  }
}
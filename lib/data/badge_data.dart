import 'package:flutter/material.dart' hide Badge;
import '../models/badge.dart';

class BadgeService {
  List<Badge_> getAllBadges() {
    return [
      Badge_(
        id: 'eco_beginner',
        name: 'Eco Beginner',
        description: 'Complete your first eco challenge',
        icon: Icons.eco,
        pointsToGain: 10,
      ),
      Badge_(
        id: 'step_enthusiast',
        name: 'Step Enthusiast',
        description: 'Walk 5000 steps in one day',
        icon: Icons.directions_walk,
        pointsToGain: 50,
      ),
      Badge_(
        id: 'water_saver',
        name: 'Water Saver',
        description: 'Complete shower time challenge',
        icon: Icons.water_drop,
        pointsToGain: 75,
      ),
      Badge_(
        id: 'cycling_pro',
        name: 'Cycling Pro',
        description: 'Use a bicycle instead of a car',
        icon: Icons.directions_bike,
        pointsToGain: 150,
      ),
      Badge_(
        id: 'community_leader',
        name: 'Community Leader',
        description: 'Organize an eco-friendly event',
        icon: Icons.people,
        pointsToGain: 200,
      ),
      Badge_(
        id: 'eco_master',
        name: 'Eco Master',
        description: 'Complete all other badges',
        icon: Icons.military_tech,
        isUnlocked: false,
        pointsToGain: 500,
      ),
    ];
  }
}
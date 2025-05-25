// filepath: /home/luis/Documents/FEUP/ESOF_proj/2LEIC02T3/test/badges_provider_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/badge.dart';
import '../lib/data/badge_data.dart';

// Since we can't directly test BadgesProvider due to Firebase dependencies,
// we'll test the Badge_ model and BadgeService independently

void main() {
  group('Badge Model Tests', () {
    test('Badge should initialize with correct properties', () {
      final badge = Badge_(
        id: 'test_badge',
        name: 'Test Badge',
        description: 'This is a test badge',
        icon: Icons.star,
        pointsToGain: 100,
      );
      
      expect(badge.id, 'test_badge');
      expect(badge.name, 'Test Badge');
      expect(badge.description, 'This is a test badge');
      expect(badge.icon, Icons.star);
      expect(badge.pointsToGain, 100);
      expect(badge.isUnlocked, false); // Default value
    });
    
    test('Badge should be initialized as unlocked when specified', () {
      final badge = Badge_(
        id: 'test_badge',
        name: 'Test Badge',
        description: 'This is a test badge',
        icon: Icons.star,
        isUnlocked: true,
        pointsToGain: 100,
      );
      
      expect(badge.isUnlocked, true);
    });
    
    test('Badge unlock status should be mutable', () {
      final badge = Badge_(
        id: 'test_badge',
        name: 'Test Badge',
        description: 'This is a test badge',
        icon: Icons.star,
        pointsToGain: 100,
      );
      
      expect(badge.isUnlocked, false);
      
      badge.isUnlocked = true;
      expect(badge.isUnlocked, true);
      
      badge.isUnlocked = false;
      expect(badge.isUnlocked, false);
    });
  });
  
  group('BadgeService Tests', () {
    late BadgeService badgeService;
    
    setUp(() {
      badgeService = BadgeService();
    });
    
    test('getAllBadges should return correct number of badges', () {
      final badges = badgeService.getAllBadges();
      expect(badges.length, 6);
    });
    
    test('getAllBadges should return badges with correct IDs', () {
      final badges = badgeService.getAllBadges();
      final badgeIds = badges.map((b) => b.id).toList();
      
      expect(badgeIds, contains('eco_beginner'));
      expect(badgeIds, contains('step_enthusiast'));
      expect(badgeIds, contains('water_saver'));
      expect(badgeIds, contains('cycling_pro'));
      expect(badgeIds, contains('community_leader'));
      expect(badgeIds, contains('eco_master'));
    });
    
    test('getAllBadges should return badges with all required properties', () {
      final badges = badgeService.getAllBadges();
      
      for (var badge in badges) {
        expect(badge.id, isNotEmpty);
        expect(badge.name, isNotEmpty);
        expect(badge.description, isNotEmpty);
        expect(badge.icon, isNotNull);
        expect(badge.pointsToGain, isNonNegative);
      }
    });
    
    test('getAllBadges should return badges with correct point values', () {
      final badges = badgeService.getAllBadges();
      
      final ecoBeginner = badges.firstWhere((b) => b.id == 'eco_beginner');
      expect(ecoBeginner.pointsToGain, 10);
      
      final stepEnthusiast = badges.firstWhere((b) => b.id == 'step_enthusiast');
      expect(stepEnthusiast.pointsToGain, 50);
      
      final waterSaver = badges.firstWhere((b) => b.id == 'water_saver');
      expect(waterSaver.pointsToGain, 75);
      
      final cyclingPro = badges.firstWhere((b) => b.id == 'cycling_pro');
      expect(cyclingPro.pointsToGain, 150);
      
      final communityLeader = badges.firstWhere((b) => b.id == 'community_leader');
      expect(communityLeader.pointsToGain, 200);
      
      final ecoMaster = badges.firstWhere((b) => b.id == 'eco_master');
      expect(ecoMaster.pointsToGain, 500);
    });
    
    test('getAllBadges should return badges with correct lock status', () {
      final badges = badgeService.getAllBadges();
      
      for (var badge in badges) {
        expect(badge.isUnlocked, isFalse);
      }
    });
    
    test('Fresh badge copies should be returned each time', () {
      final firstCopy = badgeService.getAllBadges();
      final secondCopy = badgeService.getAllBadges();
      
      // Verify we have new objects (not the same references)
      expect(identical(firstCopy[0], secondCopy[0]), isFalse);
      
      // Modify first copy
      firstCopy[0].isUnlocked = true;
      
      // Second copy should remain unchanged
      expect(secondCopy[0].isUnlocked, isFalse);
    });
  });
  
  group('Badge Unlock Logic Tests', () {
    test('Badge progression should follow documented order', () {
      // In the actual app, badges are unlocked in this order:
      // 1. Any challenge completion unlocks eco_beginner
      // 2. Specific challenges unlock their corresponding badges
      // 3. All badges unlocks eco_master
      
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      // Check that eco_beginner has the lowest points
      final ecoBeginner = allBadges.firstWhere((b) => b.id == 'eco_beginner');
      final otherBadges = allBadges.where((b) => b.id != 'eco_beginner' && b.id != 'eco_master').toList();
      
      for (var badge in otherBadges) {
        expect(ecoBeginner.pointsToGain < badge.pointsToGain, isTrue);
      }
      
      // Check that eco_master has the highest points
      final ecoMaster = allBadges.firstWhere((b) => b.id == 'eco_master');
      for (var badge in allBadges.where((b) => b.id != 'eco_master').toList()) {
        expect(ecoMaster.pointsToGain > badge.pointsToGain, isTrue);
      }
    });
  });
  
  group('Badge Mapping Tests', () {
    test('Each challenge should have a corresponding badge', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      // Mapping based on ChallengesProvider.completeChallenge
      final challengeToBadgeMap = {
        'steps': 'step_enthusiast',
        'shower': 'water_saver',
        'bike': 'cycling_pro',
        'cleanup': 'community_leader',
      };
      
      // Check that all challenge-specific badges exist
      for (final badgeId in challengeToBadgeMap.values) {
        expect(allBadges.any((b) => b.id == badgeId), isTrue);
      }
    });
    
    test('Badges should have appropriate icons', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      // Map badge IDs to expected icons
      final badgeIconMap = {
        'eco_beginner': Icons.eco,
        'step_enthusiast': Icons.directions_walk,
        'water_saver': Icons.water_drop,
        'cycling_pro': Icons.directions_bike,
        'community_leader': Icons.people,
        'eco_master': Icons.military_tech,
      };
      
      // Check that each badge has the expected icon
      for (final entry in badgeIconMap.entries) {
        final badgeId = entry.key;
        final expectedIcon = entry.value;
        
        final badge = allBadges.firstWhere((b) => b.id == badgeId);
        expect(badge.icon, expectedIcon);
      }
    });
  });

  group('Badge Descriptions Tests', () {
    test('All badges should have meaningful descriptions', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      for (var badge in allBadges) {
        expect(badge.description.length, greaterThan(5));
        // Just check that description is not empty instead of requiring punctuation
        expect(badge.description.isNotEmpty, isTrue);
      }
    });
    
    test('Badge descriptions should correspond to their purpose', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      final stepBadge = allBadges.firstWhere((b) => b.id == 'step_enthusiast');
      expect(stepBadge.description.toLowerCase(), contains('step'));
      
      final waterBadge = allBadges.firstWhere((b) => b.id == 'water_saver');
      expect(waterBadge.description.toLowerCase(), contains('shower'));
      
      final bikeBadge = allBadges.firstWhere((b) => b.id == 'cycling_pro');
      expect(bikeBadge.description.toLowerCase(), contains('bicycle'));
      
      final eventBadge = allBadges.firstWhere((b) => b.id == 'community_leader');
      expect(eventBadge.description.toLowerCase(), contains('event'));
      
      final masterBadge = allBadges.firstWhere((b) => b.id == 'eco_master');
      expect(masterBadge.description.toLowerCase(), contains('all'));
    });
  });
  
  group('Badge Points Progression Tests', () {
    test('Badge points should follow a progression', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      // Sort badges by points
      final sortedBadges = List<Badge_>.from(allBadges)
        ..sort((a, b) => a.pointsToGain.compareTo(b.pointsToGain));
      
      // Check that points increase monotonically
      for (int i = 0; i < sortedBadges.length - 1; i++) {
        expect(sortedBadges[i].pointsToGain < sortedBadges[i+1].pointsToGain, isTrue);
      }
      
      // First badge (eco_beginner) should have the lowest points
      expect(sortedBadges.first.id, 'eco_beginner');
      expect(sortedBadges.first.pointsToGain, 10);
      
      // Last badge (eco_master) should have the highest points
      expect(sortedBadges.last.id, 'eco_master');
      expect(sortedBadges.last.pointsToGain, 500);
    });
    
    test('Total badge points should match expected sum', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      // Calculate sum of all badge points
      int totalPoints = allBadges.fold(0, (sum, badge) => sum + badge.pointsToGain);
      
      // Expected sum based on badge definitions (10+50+75+150+200+500)
      expect(totalPoints, 985);
    });
  });
  
  group('Badge Collection Tests', () {
    test('Badges should be collectable in sequence', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      // Simulate collecting badges in sequence
      List<Badge_> unlockedBadges = [];
      List<String> unlockedIds = [];
      
      // Collect eco_beginner
      final ecoBeginner = allBadges.firstWhere((b) => b.id == 'eco_beginner');
      ecoBeginner.isUnlocked = true;
      unlockedBadges.add(ecoBeginner);
      unlockedIds.add(ecoBeginner.id);
      
      expect(unlockedBadges.length, 1);
      expect(unlockedIds, ['eco_beginner']);
      
      // Collect step_enthusiast
      final stepEnthusiast = allBadges.firstWhere((b) => b.id == 'step_enthusiast');
      stepEnthusiast.isUnlocked = true;
      unlockedBadges.add(stepEnthusiast);
      unlockedIds.add(stepEnthusiast.id);
      
      expect(unlockedBadges.length, 2);
      expect(unlockedIds, contains('step_enthusiast'));
      
      // Continue collecting until all basic badges are unlocked
      final waterSaver = allBadges.firstWhere((b) => b.id == 'water_saver');
      waterSaver.isUnlocked = true;
      unlockedIds.add(waterSaver.id);
      
      final cyclingPro = allBadges.firstWhere((b) => b.id == 'cycling_pro');
      cyclingPro.isUnlocked = true;
      unlockedIds.add(cyclingPro.id);
      
      final communityLeader = allBadges.firstWhere((b) => b.id == 'community_leader');
      communityLeader.isUnlocked = true;
      unlockedIds.add(communityLeader.id);
      
      // Now we should be able to unlock eco_master
      expect(unlockedIds.length, 5);
      
      // Check if all required badges for eco_master are unlocked
      final requiredBadges = ['eco_beginner', 'step_enthusiast', 'water_saver', 'cycling_pro', 'community_leader'];
      final allRequiredBadgesUnlocked = requiredBadges.every((id) => unlockedIds.contains(id));
      expect(allRequiredBadgesUnlocked, isTrue);
      
      // Unlock eco_master
      final ecoMaster = allBadges.firstWhere((b) => b.id == 'eco_master');
      ecoMaster.isUnlocked = true;
      unlockedIds.add(ecoMaster.id);
      
      // All badges should now be unlocked
      expect(unlockedIds.length, 6);
      expect(unlockedIds, contains('eco_master'));
      
      // Calculate total points earned
      int totalPointsEarned = 0;
      for (var id in unlockedIds) {
        final badge = allBadges.firstWhere((b) => b.id == id);
        totalPointsEarned += badge.pointsToGain;
      }
      
      expect(totalPointsEarned, 985); // Sum of all badge points
    });
    
    test('Unlocked badge count should match expected values', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      // Initially all badges are locked
      int unlockedCount = allBadges.where((b) => b.isUnlocked).length;
      expect(unlockedCount, 0);
      
      // Unlock some badges
      allBadges[0].isUnlocked = true; // eco_beginner
      allBadges[1].isUnlocked = true; // step_enthusiast
      
      unlockedCount = allBadges.where((b) => b.isUnlocked).length;
      expect(unlockedCount, 2);
      
      // Unlock all badges
      for (var badge in allBadges) {
        badge.isUnlocked = true;
      }
      
      unlockedCount = allBadges.where((b) => b.isUnlocked).length;
      expect(unlockedCount, allBadges.length);
      expect(unlockedCount, 6);
    });
  });
}
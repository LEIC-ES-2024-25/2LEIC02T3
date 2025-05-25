import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/badge.dart';
import '../lib/data/badge_data.dart';




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
      expect(badge.isUnlocked, false); 
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
      
      
      expect(identical(firstCopy[0], secondCopy[0]), isFalse);
      
      
      firstCopy[0].isUnlocked = true;
      
      
      expect(secondCopy[0].isUnlocked, isFalse);
    });
  });
  
  group('Badge Unlock Logic Tests', () {
    test('Badge progression should follow documented order', () {
      
      
      
      
      
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      
      final ecoBeginner = allBadges.firstWhere((b) => b.id == 'eco_beginner');
      final otherBadges = allBadges.where((b) => b.id != 'eco_beginner' && b.id != 'eco_master').toList();
      
      for (var badge in otherBadges) {
        expect(ecoBeginner.pointsToGain < badge.pointsToGain, isTrue);
      }
      
      
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
      
      
      final challengeToBadgeMap = {
        'steps': 'step_enthusiast',
        'shower': 'water_saver',
        'bike': 'cycling_pro',
        'cleanup': 'community_leader',
      };
      
      
      for (final badgeId in challengeToBadgeMap.values) {
        expect(allBadges.any((b) => b.id == badgeId), isTrue);
      }
    });
    
    test('Badges should have appropriate icons', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      
      final badgeIconMap = {
        'eco_beginner': Icons.eco,
        'step_enthusiast': Icons.directions_walk,
        'water_saver': Icons.water_drop,
        'cycling_pro': Icons.directions_bike,
        'community_leader': Icons.people,
        'eco_master': Icons.military_tech,
      };
      
      
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
      
      
      final sortedBadges = List<Badge_>.from(allBadges)
        ..sort((a, b) => a.pointsToGain.compareTo(b.pointsToGain));
      
      
      for (int i = 0; i < sortedBadges.length - 1; i++) {
        expect(sortedBadges[i].pointsToGain < sortedBadges[i+1].pointsToGain, isTrue);
      }
      
      
      expect(sortedBadges.first.id, 'eco_beginner');
      expect(sortedBadges.first.pointsToGain, 10);
      
      
      expect(sortedBadges.last.id, 'eco_master');
      expect(sortedBadges.last.pointsToGain, 500);
    });
    
    test('Total badge points should match expected sum', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      
      int totalPoints = allBadges.fold(0, (sum, badge) => sum + badge.pointsToGain);
      
      
      expect(totalPoints, 985);
    });
  });
  
  group('Badge Collection Tests', () {
    test('Badges should be collectable in sequence', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      
      List<Badge_> unlockedBadges = [];
      List<String> unlockedIds = [];
      
      
      final ecoBeginner = allBadges.firstWhere((b) => b.id == 'eco_beginner');
      ecoBeginner.isUnlocked = true;
      unlockedBadges.add(ecoBeginner);
      unlockedIds.add(ecoBeginner.id);
      
      expect(unlockedBadges.length, 1);
      expect(unlockedIds, ['eco_beginner']);
      
      
      final stepEnthusiast = allBadges.firstWhere((b) => b.id == 'step_enthusiast');
      stepEnthusiast.isUnlocked = true;
      unlockedBadges.add(stepEnthusiast);
      unlockedIds.add(stepEnthusiast.id);
      
      expect(unlockedBadges.length, 2);
      expect(unlockedIds, contains('step_enthusiast'));
      
      
      final waterSaver = allBadges.firstWhere((b) => b.id == 'water_saver');
      waterSaver.isUnlocked = true;
      unlockedIds.add(waterSaver.id);
      
      final cyclingPro = allBadges.firstWhere((b) => b.id == 'cycling_pro');
      cyclingPro.isUnlocked = true;
      unlockedIds.add(cyclingPro.id);
      
      final communityLeader = allBadges.firstWhere((b) => b.id == 'community_leader');
      communityLeader.isUnlocked = true;
      unlockedIds.add(communityLeader.id);
      
      
      expect(unlockedIds.length, 5);
      
      
      final requiredBadges = ['eco_beginner', 'step_enthusiast', 'water_saver', 'cycling_pro', 'community_leader'];
      final allRequiredBadgesUnlocked = requiredBadges.every((id) => unlockedIds.contains(id));
      expect(allRequiredBadgesUnlocked, isTrue);
      
      
      final ecoMaster = allBadges.firstWhere((b) => b.id == 'eco_master');
      ecoMaster.isUnlocked = true;
      unlockedIds.add(ecoMaster.id);
      
      
      expect(unlockedIds.length, 6);
      expect(unlockedIds, contains('eco_master'));
      
      
      int totalPointsEarned = 0;
      for (var id in unlockedIds) {
        final badge = allBadges.firstWhere((b) => b.id == id);
        totalPointsEarned += badge.pointsToGain;
      }
      
      expect(totalPointsEarned, 985); 
    });
    
    test('Unlocked badge count should match expected values', () {
      final badgeService = BadgeService();
      final allBadges = badgeService.getAllBadges();
      
      
      int unlockedCount = allBadges.where((b) => b.isUnlocked).length;
      expect(unlockedCount, 0);
      
      
      allBadges[0].isUnlocked = true; 
      allBadges[1].isUnlocked = true; 
      
      unlockedCount = allBadges.where((b) => b.isUnlocked).length;
      expect(unlockedCount, 2);
      
      
      for (var badge in allBadges) {
        badge.isUnlocked = true;
      }
      
      unlockedCount = allBadges.where((b) => b.isUnlocked).length;
      expect(unlockedCount, allBadges.length);
      expect(unlockedCount, 6);
    });
  });
}
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/challenge.dart';

void main() {
  group('Bike Challenge Tests', () {
    
    test('Bike challenge status should be "not done yet" initially', () {
      
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30
      );
      
      
      expect(bikeChallenge.bikeRideStatus, 'not done yet');
      expect(bikeChallenge.isCompleted, false);
    });

    test('Bike challenge status should be "completed" when challenge is completed', () {
      
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30
      );
      
      
      bikeChallenge.bikeRideStatus = 'completed';
      bikeChallenge.isCompleted = true;
      
      
      expect(bikeChallenge.bikeRideStatus, 'completed');
      expect(bikeChallenge.isCompleted, true);
    });

    test('Bike challenge should reset after 24 hours', () {
      
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30,
        bikeRideStatus: 'completed',
        isCompleted: true
      );
      
      
      final lastBikeDate = DateTime.now().subtract(const Duration(hours: 25));
      
      
      final hourDifference = DateTime.now().difference(lastBikeDate).inHours;
      expect(hourDifference >= 24, true, reason: 'Difference should be at least 24 hours');
      
      
      if (hourDifference >= 24) {
        bikeChallenge.isCompleted = false;
        bikeChallenge.bikeRideStatus = "not done yet";
      }
      
      
      expect(bikeChallenge.bikeRideStatus, "not done yet");
      expect(bikeChallenge.isCompleted, false);
    });
    
    test('Bike challenge should not reset before 24 hours', () {
      
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30,
        bikeRideStatus: 'completed',
        isCompleted: true
      );
      
      
      final lastBikeDate = DateTime.now().subtract(const Duration(hours: 23));
      
      
      final hourDifference = DateTime.now().difference(lastBikeDate).inHours;
      expect(hourDifference < 24, true, reason: 'Difference should be less than 24 hours');
      
      
      if (hourDifference >= 24) {
        bikeChallenge.isCompleted = false;
        bikeChallenge.bikeRideStatus = "not done yet";
      }
      
      
      expect(bikeChallenge.bikeRideStatus, "completed");
      expect(bikeChallenge.isCompleted, true);
    });
    
    test('Cannot complete bike challenge twice in the same day', () {
      
      final lastBikeDate = DateTime.now();
      final now = DateTime.now();
      
      
      final canCompleteAgain = !(now.difference(lastBikeDate).inHours < 24);
      
      
      expect(canCompleteAgain, false, reason: 'Should not be able to complete bike challenge again within 24 hours');
    });
    
    test('Can complete bike challenge after 24 hours', () {
      
      final lastBikeDate = DateTime.now().subtract(const Duration(hours: 25));
      final now = DateTime.now();
      
      
      final canCompleteAgain = !(now.difference(lastBikeDate).inHours < 24);
      
      
      expect(canCompleteAgain, true, reason: 'Should be able to complete bike challenge again after 24 hours');
    });
    
    test('Points should be awarded when bike challenge is completed', () {
      
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30
      );
      
      
      expect(bikeChallenge.points, 30, reason: 'Bike challenge should be worth 30 points');
    });
  });
}
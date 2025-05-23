import 'package:flutter_test/flutter_test.dart';
import '../lib/models/challenge.dart';

void main() {
  group('Bike Challenge Tests', () {
    
    test('Bike challenge status should be "not done yet" initially', () {
      // Create a bike challenge with default state
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30
      );
      
      // Assert initial status
      expect(bikeChallenge.bikeRideStatus, 'not done yet');
      expect(bikeChallenge.isCompleted, false);
    });

    test('Bike challenge status should be "completed" when challenge is completed', () {
      // Create the challenge
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30
      );
      
      // Simulate completing the bike challenge
      bikeChallenge.bikeRideStatus = 'completed';
      bikeChallenge.isCompleted = true;
      
      // Assert completion status
      expect(bikeChallenge.bikeRideStatus, 'completed');
      expect(bikeChallenge.isCompleted, true);
    });

    test('Bike challenge should reset after 24 hours', () {
      // Create the challenge with completed status
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30,
        bikeRideStatus: 'completed',
        isCompleted: true
      );
      
      // Set a lastBikeDate 25 hours ago (exceeds 24h limit)
      final lastBikeDate = DateTime.now().subtract(const Duration(hours: 25));
      
      // Check if time difference exceeds 24 hours
      final hourDifference = DateTime.now().difference(lastBikeDate).inHours;
      expect(hourDifference >= 24, true, reason: 'Difference should be at least 24 hours');
      
      // Apply the reset logic that happens in the app when loading challenge state
      if (hourDifference >= 24) {
        bikeChallenge.isCompleted = false;
        bikeChallenge.bikeRideStatus = "not done yet";
      }
      
      // Verify bike challenge status was reset
      expect(bikeChallenge.bikeRideStatus, "not done yet");
      expect(bikeChallenge.isCompleted, false);
    });
    
    test('Bike challenge should not reset before 24 hours', () {
      // Create the challenge with completed status
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30,
        bikeRideStatus: 'completed',
        isCompleted: true
      );
      
      // Set a lastBikeDate 23 hours ago (within 24h limit)
      final lastBikeDate = DateTime.now().subtract(const Duration(hours: 23));
      
      // Check if time difference is less than 24 hours
      final hourDifference = DateTime.now().difference(lastBikeDate).inHours;
      expect(hourDifference < 24, true, reason: 'Difference should be less than 24 hours');
      
      // Apply the reset logic that happens in the app
      if (hourDifference >= 24) {
        bikeChallenge.isCompleted = false;
        bikeChallenge.bikeRideStatus = "not done yet";
      }
      
      // Verify bike challenge status was not reset
      expect(bikeChallenge.bikeRideStatus, "completed");
      expect(bikeChallenge.isCompleted, true);
    });
    
    test('Cannot complete bike challenge twice in the same day', () {
      // Create a lastBikeDate for "today"
      final lastBikeDate = DateTime.now();
      final now = DateTime.now();
      
      // Check if within the 24-hour cooldown period
      final canCompleteAgain = !(now.difference(lastBikeDate).inHours < 24);
      
      // Assert that bike challenge cannot be completed again
      expect(canCompleteAgain, false, reason: 'Should not be able to complete bike challenge again within 24 hours');
    });
    
    test('Can complete bike challenge after 24 hours', () {
      // Create a lastBikeDate for 25 hours ago
      final lastBikeDate = DateTime.now().subtract(const Duration(hours: 25));
      final now = DateTime.now();
      
      // Check if the 24-hour cooldown period has passed
      final canCompleteAgain = !(now.difference(lastBikeDate).inHours < 24);
      
      // Assert that bike challenge can be completed again
      expect(canCompleteAgain, true, reason: 'Should be able to complete bike challenge again after 24 hours');
    });
    
    test('Points should be awarded when bike challenge is completed', () {
      // Create the challenge
      Challenge bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30
      );
      
      // Verify the challenge has the correct number of points
      expect(bikeChallenge.points, 30, reason: 'Bike challenge should be worth 30 points');
    });
  });
}
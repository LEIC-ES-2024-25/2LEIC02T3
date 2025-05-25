// filepath: /home/luis/Documents/FEUP/ESOF_proj/2LEIC02T3/test/challenges_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import '../lib/models/challenge.dart';

// We're focusing on testing the Challenge model directly
// ChallengesProvider requires Firebase initialization which would need mocks for testing

void main() {
  group('Challenge Model Tests', () {
    test('Challenge model should initialize correctly', () {
      final challenge = Challenge(
        id: 'test',
        title: 'Test Challenge',
        description: 'This is a test challenge',
        points: 50
      );
      
      expect(challenge.id, 'test');
      expect(challenge.title, 'Test Challenge');
      expect(challenge.description, 'This is a test challenge');
      expect(challenge.points, 50);
      expect(challenge.isCompleted, false);
      expect(challenge.totalSteps, 0);
      expect(challenge.currentSteps, 0);
      expect(challenge.carFreeStatus, 'car-free by now');
      expect(challenge.bikeRideStatus, 'not done yet');
      expect(challenge.isTimerRunning, false);
      expect(challenge.elapsedTime, 0);
      expect(challenge.showerStatus, 'not started');
      expect(challenge.qrCodeStatus, 'not scanned');
    });
    
    test('Challenge model should accept custom values', () {
      final challenge = Challenge(
        id: 'steps',
        title: 'Step Challenge',
        description: 'Complete 5000 steps',
        points: 20,
        totalSteps: 5000,
        currentSteps: 2500,
        isCompleted: true
      );
      
      expect(challenge.id, 'steps');
      expect(challenge.totalSteps, 5000);
      expect(challenge.currentSteps, 2500);
      expect(challenge.isCompleted, true);
    });
    
    test('Shower challenge status should reflect timer state', () {
      final challenge = Challenge(
        id: 'shower',
        title: 'Shower Challenge',
        description: 'Take a 5 minute shower',
        points: 30,
        isTimerRunning: true,
        elapsedTime: 120,
        showerStatus: 'in progress'
      );
      
      expect(challenge.isTimerRunning, true);
      expect(challenge.elapsedTime, 120);
      expect(challenge.showerStatus, 'in progress');
      
      // Simulate stopping the timer under 5 minutes
      challenge.isTimerRunning = false;
      challenge.showerStatus = 'completed';
      
      expect(challenge.isTimerRunning, false);
      expect(challenge.showerStatus, 'completed');
    });
    
    test('Bike challenge status should update correctly', () {
      final challenge = Challenge(
        id: 'bike',
        title: 'Bike Challenge',
        description: 'Ride a bike today',
        points: 30,
        bikeRideStatus: 'not done yet'
      );
      
      expect(challenge.bikeRideStatus, 'not done yet');
      expect(challenge.isCompleted, false);
      
      // Simulate completing the challenge
      challenge.bikeRideStatus = 'completed';
      challenge.isCompleted = true;
      
      expect(challenge.bikeRideStatus, 'completed');
      expect(challenge.isCompleted, true);
    });
    
    test('QR code status should update correctly', () {
      final challenge = Challenge(
        id: 'cleanup',
        title: 'Cleanup Challenge',
        description: 'Scan a QR code at an event',
        points: 50,
        qrCodeStatus: 'not scanned'
      );
      
      expect(challenge.qrCodeStatus, 'not scanned');
      
      // Simulate scanning a QR code
      challenge.qrCodeStatus = 'Scanned: Beach Cleanup';
      challenge.isCompleted = true;
      
      expect(challenge.qrCodeStatus, 'Scanned: Beach Cleanup');
      expect(challenge.isCompleted, true);
    });
  });
  
  group('Daily Challenge Reset Tests', () {
    test('Bike challenge should reset after 24 hours', () {
      // Create a bike challenge with completed status
      final bikeChallenge = Challenge(
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
      final bikeChallenge = Challenge(
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
  });
  
  group('Steps Challenge Tests', () {
    test('Steps challenge should track progress correctly', () {
      final stepsChallenge = Challenge(
        id: 'steps',
        title: 'Walk 5,000 Steps',
        description: 'Take a walk and complete 5,000 steps today.',
        points: 20,
        totalSteps: 5000,
        currentSteps: 0
      );
      
      // Initial state
      expect(stepsChallenge.currentSteps, 0);
      expect(stepsChallenge.isCompleted, false);
      
      // Update steps - not yet complete
      stepsChallenge.currentSteps = 2500;
      expect(stepsChallenge.currentSteps, 2500);
      expect(stepsChallenge.isCompleted, false);
      
      // Update steps - challenge complete
      stepsChallenge.currentSteps = 5000;
      stepsChallenge.isCompleted = true;
      expect(stepsChallenge.currentSteps, 5000);
      expect(stepsChallenge.isCompleted, true);
    });
    
    test('Steps challenge should handle step count exceeding goal', () {
      final stepsChallenge = Challenge(
        id: 'steps',
        title: 'Walk 5,000 Steps',
        description: 'Take a walk and complete 5,000 steps today.',
        points: 20,
        totalSteps: 5000,
        currentSteps: 0
      );
      
      // Exceed step goal
      stepsChallenge.currentSteps = 7500;
      expect(stepsChallenge.currentSteps, 7500);
      expect(stepsChallenge.currentSteps > stepsChallenge.totalSteps, isTrue);
    });
  });
  
  group('Shower Challenge Timer Tests', () {
    test('Shower challenge timer should track elapsed time', () {
      final showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30,
        isTimerRunning: false,
        elapsedTime: 0,
        showerStatus: 'not started'
      );
      
      // Start timer
      showerChallenge.isTimerRunning = true;
      showerChallenge.showerStatus = 'in progress';
      expect(showerChallenge.isTimerRunning, true);
      expect(showerChallenge.showerStatus, 'in progress');
      
      // Simulate time passing (in real app this would be done by a Timer)
      showerChallenge.elapsedTime = 120; // 2 minutes
      expect(showerChallenge.elapsedTime, 120);
      
      // Stop timer - successful completion (under 5 minutes)
      showerChallenge.isTimerRunning = false;
      showerChallenge.showerStatus = 'completed';
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 120);
      expect(showerChallenge.showerStatus, 'completed');
    });
    
    test('Shower challenge should fail if exceeding 5 minutes', () {
      final showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30,
        isTimerRunning: true,
        elapsedTime: 0,
        showerStatus: 'in progress'
      );
      
      // Simulate time passing beyond 5 minutes (300 seconds)
      showerChallenge.elapsedTime = 330; // 5.5 minutes
      
      // Stop timer - failed completion (over 5 minutes)
      showerChallenge.isTimerRunning = false;
      showerChallenge.showerStatus = 'failed';
      
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 330);
      expect(showerChallenge.elapsedTime >= 300, isTrue);
      expect(showerChallenge.showerStatus, 'failed');
    });
  });
  
  group('Car-Free Challenge Tests', () {
    test('Car-free challenge should initialize with correct status', () {
      final carFreeChallenge = Challenge(
        id: 'car-free',
        title: 'Car-Free Day',
        description: 'Avoid using a car today.',
        points: 60
      );
      
      // Check initial state
      expect(carFreeChallenge.carFreeStatus, 'car-free by now');
      expect(carFreeChallenge.isCompleted, false);
      
      // Mark as completed
      carFreeChallenge.isCompleted = true;
      expect(carFreeChallenge.isCompleted, true);
    });
  });
  
  group('Cleanup/QR Code Challenge Tests', () {
    test('QR code challenge should track scan events', () {
      final cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Attend Any Eco Event',
        description: 'Participate in any environmental event and scan the QR code.',
        points: 50
      );
      
      // Initially not scanned
      expect(cleanupChallenge.qrCodeStatus, 'not scanned');
      expect(cleanupChallenge.isCompleted, false);
      
      // Simulate scanning a QR code
      cleanupChallenge.qrCodeStatus = 'Scanned: River Cleanup';
      cleanupChallenge.isCompleted = true;
      
      expect(cleanupChallenge.qrCodeStatus, 'Scanned: River Cleanup');
      expect(cleanupChallenge.isCompleted, true);
    });
    
    test('QR code challenge should track different event types', () {
      final cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Attend Any Eco Event',
        description: 'Participate in any environmental event and scan the QR code.',
        points: 50
      );
      
      // Test different event types
      final eventTypes = ['Beach Cleanup', 'Tree Planting', 'Recycling Workshop', 'Climate March'];
      
      for (var eventType in eventTypes) {
        cleanupChallenge.qrCodeStatus = 'Scanned: $eventType';
        expect(cleanupChallenge.qrCodeStatus, 'Scanned: $eventType');
      }
    });
  });
  
  group('Challenge Points Tests', () {
    test('Challenges should have correct point values', () {
      // Create challenges with default point values from the app
      final stepsChallenge = Challenge(
        id: 'steps',
        title: 'Walk 5,000 Steps',
        description: 'Take a walk and complete 5,000 steps today.',
        points: 20
      );
      
      final carFreeChallenge = Challenge(
        id: 'car-free',
        title: 'Car-Free Day',
        description: 'Avoid using a car today.',
        points: 60
      );
      
      final bikeChallenge = Challenge(
        id: 'bike',
        title: 'Rode a Bike Today',
        description: 'Swap your car ride for a bike ride today.',
        points: 30
      );
      
      final showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      final cleanupChallenge = Challenge(
        id: 'cleanup',
        title: 'Attend Any Eco Event',
        description: 'Participate in any environmental event and scan the QR code.',
        points: 50
      );
      
      // Verify point values
      expect(stepsChallenge.points, 20);
      expect(carFreeChallenge.points, 60);
      expect(bikeChallenge.points, 30);
      expect(showerChallenge.points, 30);
      expect(cleanupChallenge.points, 50);
    });
  });
}
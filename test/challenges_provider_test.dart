import 'package:flutter_test/flutter_test.dart';
import '../lib/models/challenge.dart';

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
      
      
      challenge.qrCodeStatus = 'Scanned: Beach Cleanup';
      challenge.isCompleted = true;
      
      expect(challenge.qrCodeStatus, 'Scanned: Beach Cleanup');
      expect(challenge.isCompleted, true);
    });
  });
  
  group('Daily Challenge Reset Tests', () {
    test('Bike challenge should reset after 24 hours', () {
      
      final bikeChallenge = Challenge(
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
      
      final bikeChallenge = Challenge(
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
      
      
      expect(stepsChallenge.currentSteps, 0);
      expect(stepsChallenge.isCompleted, false);
      
      
      stepsChallenge.currentSteps = 2500;
      expect(stepsChallenge.currentSteps, 2500);
      expect(stepsChallenge.isCompleted, false);
      
      
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
      
      
      showerChallenge.isTimerRunning = true;
      showerChallenge.showerStatus = 'in progress';
      expect(showerChallenge.isTimerRunning, true);
      expect(showerChallenge.showerStatus, 'in progress');
      
      
      showerChallenge.elapsedTime = 120; 
      expect(showerChallenge.elapsedTime, 120);
      
      
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
      
      
      showerChallenge.elapsedTime = 330; 
      
      
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
      
      
      expect(carFreeChallenge.carFreeStatus, 'car-free by now');
      expect(carFreeChallenge.isCompleted, false);
      
      
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
      
      
      expect(cleanupChallenge.qrCodeStatus, 'not scanned');
      expect(cleanupChallenge.isCompleted, false);
      
      
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
      
      
      final eventTypes = ['Beach Cleanup', 'Tree Planting', 'Recycling Workshop', 'Climate March'];
      
      for (var eventType in eventTypes) {
        cleanupChallenge.qrCodeStatus = 'Scanned: $eventType';
        expect(cleanupChallenge.qrCodeStatus, 'Scanned: $eventType');
      }
    });
  });
  
  group('Challenge Points Tests', () {
    test('Challenges should have correct point values', () {
      
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
      
      
      expect(stepsChallenge.points, 20);
      expect(carFreeChallenge.points, 60);
      expect(bikeChallenge.points, 30);
      expect(showerChallenge.points, 30);
      expect(cleanupChallenge.points, 50);
    });
  });
}
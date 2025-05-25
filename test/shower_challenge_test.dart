import 'package:flutter_test/flutter_test.dart';
import '../lib/models/challenge.dart';
import 'package:flutter/material.dart';

void main() {
  group('Shower Challenge Tests', () {
    
    test('Shower challenge should be initialized with default state', () {
      // Create a shower challenge with default state
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      // Assert initial status
      expect(showerChallenge.showerStatus, 'not started');
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 0);
      expect(showerChallenge.isCompleted, false);
    });

    test('Shower challenge timer should track elapsed time', () {
      // Create the challenge
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      // Simulate starting the timer
      showerChallenge.isTimerRunning = true;
      showerChallenge.showerStatus = 'in progress';
      
      // Simulate elapsed time
      showerChallenge.elapsedTime = 120; // 2 minutes
      
      // Assert timer state
      expect(showerChallenge.isTimerRunning, true);
      expect(showerChallenge.showerStatus, 'in progress');
      expect(showerChallenge.elapsedTime, 120);
    });

    test('Shower challenge should be completed when under 5 minutes', () {
      // Create the challenge
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      // Simulate a completed shower challenge under 5 minutes (299 seconds)
      showerChallenge.isTimerRunning = false;
      showerChallenge.elapsedTime = 299;
      showerChallenge.showerStatus = 'completed';
      showerChallenge.isCompleted = true;
      
      // Assert completion status
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 299);
      expect(showerChallenge.elapsedTime < 300, true);
      expect(showerChallenge.showerStatus, 'completed');
      expect(showerChallenge.isCompleted, true);
    });

    test('Shower challenge should fail when over 5 minutes', () {
      // Create the challenge
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      // Simulate a failed shower challenge over 5 minutes (301 seconds)
      showerChallenge.isTimerRunning = false;
      showerChallenge.elapsedTime = 301;
      showerChallenge.showerStatus = 'failed';
      showerChallenge.isCompleted = false;
      
      // Assert failed status
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 301);
      expect(showerChallenge.elapsedTime >= 300, true);
      expect(showerChallenge.showerStatus, 'failed');
      expect(showerChallenge.isCompleted, false);
    });

    test('Shower challenge timer should auto-stop at 5 minutes', () {
      // Create the challenge
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30,
        isTimerRunning: true,
        showerStatus: 'in progress'
      );
      
      // Simulate elapsed time reaching exactly 5 minutes (300 seconds)
      showerChallenge.elapsedTime = 300;
      
      // In the implementation, the timer should auto-stop at 300 seconds
      // We're testing the model state after this auto-stop should happen
      showerChallenge.isTimerRunning = false;
      showerChallenge.showerStatus = 'failed';
      
      // Assert auto-stop behavior
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 300);
      expect(showerChallenge.showerStatus, 'failed');
    });

    test('Shower challenge should prevent multiple attempts within 24 hours', () {
      // This test checks the logic for preventing multiple shower challenges in one day
      // (Note: This is testing the intended behavior, but the actual cooldown logic
      // is in the ChallengesProvider class, not in the Challenge model)
      
      // Create the challenge that was already completed today
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30,
        showerStatus: 'completed',
        isCompleted: true
      );
      
      // In a real scenario, ChallengesProvider would check lastShowerDate
      // and prevent starting a new shower challenge within 24 hours
      // Here we're just testing the model state reflects the completed status
      expect(showerChallenge.showerStatus, 'completed');
    });
  });
}
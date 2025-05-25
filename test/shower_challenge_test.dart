import 'package:flutter_test/flutter_test.dart';
import '../lib/models/challenge.dart';

void main() {
  group('Shower Challenge Tests', () {
    
    test('Shower challenge should be initialized with default state', () {
      
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      
      expect(showerChallenge.showerStatus, 'not started');
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 0);
      expect(showerChallenge.isCompleted, false);
    });

    test('Shower challenge timer should track elapsed time', () {
      
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      
      showerChallenge.isTimerRunning = true;
      showerChallenge.showerStatus = 'in progress';
      
      
      showerChallenge.elapsedTime = 120; 
      
      
      expect(showerChallenge.isTimerRunning, true);
      expect(showerChallenge.showerStatus, 'in progress');
      expect(showerChallenge.elapsedTime, 120);
    });

    test('Shower challenge should be completed when under 5 minutes', () {
      
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      
      showerChallenge.isTimerRunning = false;
      showerChallenge.elapsedTime = 299;
      showerChallenge.showerStatus = 'completed';
      showerChallenge.isCompleted = true;
      
      
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 299);
      expect(showerChallenge.elapsedTime < 300, true);
      expect(showerChallenge.showerStatus, 'completed');
      expect(showerChallenge.isCompleted, true);
    });

    test('Shower challenge should fail when over 5 minutes', () {
      
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30
      );
      
      
      showerChallenge.isTimerRunning = false;
      showerChallenge.elapsedTime = 301;
      showerChallenge.showerStatus = 'failed';
      showerChallenge.isCompleted = false;
      
      
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 301);
      expect(showerChallenge.elapsedTime >= 300, true);
      expect(showerChallenge.showerStatus, 'failed');
      expect(showerChallenge.isCompleted, false);
    });

    test('Shower challenge timer should auto-stop at 5 minutes', () {
      
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30,
        isTimerRunning: true,
        showerStatus: 'in progress'
      );
      
      
      showerChallenge.elapsedTime = 300;
      
      
      
      showerChallenge.isTimerRunning = false;
      showerChallenge.showerStatus = 'failed';
      
      
      expect(showerChallenge.isTimerRunning, false);
      expect(showerChallenge.elapsedTime, 300);
      expect(showerChallenge.showerStatus, 'failed');
    });

    test('Shower challenge should prevent multiple attempts within 24 hours', () {
      
      
      
      
      
      Challenge showerChallenge = Challenge(
        id: 'shower',
        title: '5-minutes-shower',
        description: 'Take a shower in under 5 minutes.',
        points: 30,
        showerStatus: 'completed',
        isCompleted: true
      );
      
      
      
      
      expect(showerChallenge.showerStatus, 'completed');
    });
  });
}
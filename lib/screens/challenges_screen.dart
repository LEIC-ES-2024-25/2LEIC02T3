import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:app_usage/app_usage.dart'; // Import the app_usage package
import '../models/challenge.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> challenges = [
    Challenge(
      title: "Walk 5,000 Steps",
      description: "Take a walk and complete 5,000 steps today.",
      points: 20,
      totalSteps: 5000,
      currentSteps: 0,
    ),
  ];

  //----------------------------------------------------------------------------
  //trackers and timers----------------------------------------------------------------------------

  StreamSubscription<StepCount>? _stepCountStream;
  int _lastRecordedStepCount = 0; // Tracks the step count at the start of the day
  DateTime? _lastRecordedDate; // Tracks the last recorded date


  //----------------------------------------------------------------------------
  //count steps----------------------------------------------------------------------------

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastRecordedStepCount = prefs.getInt('lastRecordedStepCount') ?? 0;
      _lastRecordedDate =
          DateTime.tryParse(prefs.getString('lastRecordedDate') ?? '');
    });
  }

  Future<void> _saveData(int stepCount, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastRecordedStepCount', stepCount);
    await prefs.setString('lastRecordedDate', date.toString());
  }

  void _startListeningToSteps() {
    _stepCountStream = Pedometer.stepCountStream.listen((StepCount event) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Check if it's a new day
      if (_lastRecordedDate == null || _lastRecordedDate!.isBefore(today)) {
        // Reset the step count for the new day
        _lastRecordedStepCount = event.steps;
        _lastRecordedDate = today;
        _saveData(_lastRecordedStepCount, _lastRecordedDate!);
      }

      // Initialize _lastRecordedStepCount if it's not set yet
      if (_lastRecordedStepCount == 0) {
        _lastRecordedStepCount = event.steps;
        _lastRecordedDate = today;
        _saveData(_lastRecordedStepCount, _lastRecordedDate!);
      }

      // Ensure _lastRecordedStepCount is not greater than the current step count
      if (_lastRecordedStepCount > event.steps) {
        _lastRecordedStepCount = event.steps;
        _saveData(_lastRecordedStepCount, _lastRecordedDate!);
      }

      // Update the current steps for today
      final todaySteps = event.steps - _lastRecordedStepCount;

      setState(() {
        challenges[0].currentSteps = todaySteps;

        // Check if the user has completed the current challenge
        if (challenges[0].currentSteps >= challenges[0].totalSteps) {
          // Update the challenge based on the current totalSteps
          if (challenges[0].totalSteps == 5000) {
            challenges[0] = Challenge(
              title: "Walk 10,000 Steps",
              description: "Take a walk and complete 10,000 steps today.",
              points: 40,
              totalSteps: 10000,
              currentSteps: 0,
            );
          } else if (challenges[0].totalSteps == 10000) {
            challenges[0] = Challenge(
              title: "Walk 20,000 Steps",
              description: "Take a walk and complete 20,000 steps today.",
              points: 60,
              totalSteps: 20000,
              currentSteps: 0,
            );
          } else if (challenges[0].totalSteps == 20000) {
            challenges[0] = Challenge(
              title: "Walk 50,000 Steps",
              description: "Take a walk and complete 50,000 steps today.",
              points: 100,
              totalSteps: 50000,
              currentSteps: 0,
            );
          }
        }
      });
    });
  }


  //----------------------------------------------------------------------------
  //----------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Load saved data (including last shower date)
    _loadSavedData().then((_) {
      _startListeningToSteps();
    });

    _loadShowerState();

    // Start listening to activity recognition
    _subscribeActivityStream();

    // Get total screen time and start a periodic timer to update it every 5 minutes
    getTotalScreenTime();
    _screenTimeUpdateTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      getTotalScreenTime();
    });
  }

  @override
  void dispose() {
    // Cancel the step count stream subscription
    _stepCountStream?.cancel();

    // Cancel the activity recognition stream subscription
    _activitySubscription?.cancel();

    // Cancel the shower timer if it's running
    _showerTimer?.cancel();

    // Cancel the periodic screen time update timer
    _screenTimeUpdateTimer?.cancel();

    super.dispose();
  }

//----------------------------------------------------------------------------
//front-end----------------------------------------------------------------------------

}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import '../models/challenge.dart';
import '../providers/points_provider.dart';
import '../providers/badges_provider.dart';
import '../services/notification_service.dart';

class ChallengesProvider with ChangeNotifier {
  List<Challenge> _challenges = [];
  Timer? _showerTimer;
  int _lastRecordedStepCount = 0;
  DateTime? _lastRecordedDate;
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  bool _stepGoalAchieved = false;
  String _completedStepGoal = '';
  
  // Activity recognition properties
  StreamSubscription<Activity>? _activitySubscription;
  
  List<Challenge> get challenges => _challenges;
  bool get isShowerTimerRunning => _challenges.any((c) => c.id == 'shower' && c.isTimerRunning);
  int get showerElapsedTime => _challenges.firstWhere((c) => c.id == 'shower', orElse: () => Challenge(
    id: 'shower',
    title: '',
    description: '',
    points: 0,
    elapsedTime: 0,
  )).elapsedTime;
  bool get stepGoalAchieved => _stepGoalAchieved;
  String get completedStepGoal => _completedStepGoal;
  
  ChallengesProvider() {
    _initChallenges();
    _initStepCounter();
    _initActivityRecognition();
  }
  
  void _initChallenges() {
    _challenges = [
      Challenge(
        id: 'steps',
        title: "Walk 5,000 Steps",
        description: "Take a walk and complete 5,000 steps today.",
        points: 20,
        totalSteps: 5000,
        currentSteps: 0,
      ),
      Challenge(
        id: 'car-free',
        title: "Car-Free Day",
        description: "Avoid using a car today.",
        points: 60,
        carFreeStatus: "car-free by now",
      ),
      Challenge(
        id: 'bike',
        title: "Rode a Bike Today",
        description: "Swap your car ride for a bike ride today.",
        points: 30,
        bikeRideStatus: "not done yet",
      ),
      Challenge(
        id: 'shower',
        title: "5-minutes-shower",
        description: "Take a shower in under 5 minutes.",
        points: 30,
        isTimerRunning: false,
        elapsedTime: 0,
        showerStatus: "not started",
      ),
      Challenge(
        id: 'screen-time',
        title: "Screen Time",
        description: "Limit your screen time to 2 hours.",
        points: 80,
        totalSteps: 120, // 2 hours
        currentSteps: 0, // Track screen time
      ),
      Challenge(
        id: 'cleanup',
        title: "Go to Clean-up Event",
        description: "Participate in a clean-up event today.",
        points: 50,
        qrCodeStatus: "not scanned",
      ),
    ];
    _loadChallengeState();
  }
  
  @override
  void dispose() {
    _showerTimer?.cancel();
    _stepCountSubscription?.cancel();
    _activitySubscription?.cancel();
    super.dispose();
  }
  
  // PERSISTENCE METHODS
  Future<void> _loadChallengeState() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load steps challenge
    final currentSteps = prefs.getInt('currentSteps') ?? 0;
    final totalSteps = prefs.getInt('totalSteps') ?? 5000;
    _lastRecordedStepCount = prefs.getInt('lastRecordedStepCount') ?? 0;
    final lastDateString = prefs.getString('lastRecordedDate');
    if (lastDateString != null) {
      _lastRecordedDate = DateTime.tryParse(lastDateString);
    }
    
    // Load shower challenge
    final elapsedTime = prefs.getInt('showerElapsedTime') ?? 0;
    final showerStatus = prefs.getString('showerStatus') ?? "not started";
    
    // Load car-free challenge
    final carFreeStatus = prefs.getString('carFreeStatus') ?? "car-free by now";
    
    // Load bike challenge
    final bikeRideStatus = prefs.getString('bikeRideStatus') ?? "not done yet";
    
    // Load screen time challenge
    final screenTimeMinutes = prefs.getInt('screenTimeMinutes') ?? 0;
    
    // Load clean-up event challenge
    final qrCodeStatus = prefs.getString('qrCodeStatus') ?? "not scanned";
    
    // Update challenges
    final stepsChallenge = _challenges.firstWhere((c) => c.id == 'steps');
    stepsChallenge.totalSteps = totalSteps;
    stepsChallenge.currentSteps = currentSteps;
    
    final showerChallenge = _challenges.firstWhere((c) => c.id == 'shower');
    showerChallenge.elapsedTime = elapsedTime;
    showerChallenge.showerStatus = showerStatus;
    
    final carFreeChallenge = _challenges.firstWhere((c) => c.id == 'car-free');
    carFreeChallenge.carFreeStatus = carFreeStatus;
    
    final bikeChallenge = _challenges.firstWhere((c) => c.id == 'bike');
    bikeChallenge.bikeRideStatus = bikeRideStatus;
    
    final screenTimeChallenge = _challenges.firstWhere((c) => c.id == 'screen-time');
    screenTimeChallenge.currentSteps = screenTimeMinutes;
    
    final cleanupChallenge = _challenges.firstWhere((c) => c.id == 'cleanup');
    cleanupChallenge.qrCodeStatus = qrCodeStatus;
    
    notifyListeners();
  }
  
  Future<void> _saveStepData(int stepCount, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastRecordedStepCount', stepCount);
    await prefs.setString('lastRecordedDate', date.toIso8601String());
    
    final stepsChallenge = _challenges.firstWhere((c) => c.id == 'steps');
    await prefs.setInt('currentSteps', stepsChallenge.currentSteps);
    await prefs.setInt('totalSteps', stepsChallenge.totalSteps);
  }
  
  Future<void> _saveShowerState() async {
    final prefs = await SharedPreferences.getInstance();
    final showerChallenge = _challenges.firstWhere((c) => c.id == 'shower');
    await prefs.setInt('showerElapsedTime', showerChallenge.elapsedTime);
    await prefs.setString('showerStatus', showerChallenge.showerStatus);
  }
  
  Future<void> markShowerChallengeUsedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await prefs.setString('lastShowerDate', today.toIso8601String());
  }
  
  Future<bool> hasShowerChallengeBeenUsedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShowerDate = prefs.getString('lastShowerDate');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastShowerDate == null) {
      return false;
    }

    final lastDate = DateTime.tryParse(lastShowerDate);
    if (lastDate == null) {
      return false;
    }

    return DateTime(lastDate.year, lastDate.month, lastDate.day).isAtSameMomentAs(today);
  }
  
  // STEP COUNTER METHODS
  void _initStepCounter() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountSubscription = _stepCountStream?.listen(_onStepCount);
  }
  
  void _onStepCount(StepCount event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastRecordedDate == null) {
      _lastRecordedStepCount = event.steps;
      _lastRecordedDate = today;
      _saveStepData(_lastRecordedStepCount, _lastRecordedDate!);
      return;
    }
    
    if (!_lastRecordedDate!.isAtSameMomentAs(today)) {
      _lastRecordedStepCount = event.steps;
      _lastRecordedDate = today;
      _saveStepData(_lastRecordedStepCount, _lastRecordedDate!);
    }
    
    // Update the current steps for today
    final todaySteps = event.steps - _lastRecordedStepCount;
    final stepsChallenge = _challenges.firstWhere((c) => c.id == 'steps');
    stepsChallenge.currentSteps = todaySteps;

    // Update the background notification with current steps
    NotificationService().showStepCountNotification(stepsChallenge.currentSteps);
    
    // Continue with any other updates and notify listeners
    notifyListeners();
  }
  
  // SHOWER METHODS
  void toggleShowerTimer(BuildContext context) async {
    final hasBeenUsedToday = await hasShowerChallengeBeenUsedToday();
    if (hasBeenUsedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can only take the 5-minute shower challenge once per day!"),
        ),
      );
      return;
    }

    final showerChallenge = _challenges.firstWhere((c) => c.id == 'shower');

    if (showerChallenge.isTimerRunning) {
      _showerTimer?.cancel();
      showerChallenge.isTimerRunning = false;

      print("Shower elapsed time: ${showerChallenge.elapsedTime} seconds");

      // Award points only if the elapsed time is under 300 sec (5 minutes)
      if (showerChallenge.elapsedTime < 300) {
        showerChallenge.showerStatus = "completed";
        await markShowerChallengeUsedToday();
        await completeChallenge('shower', context);
      } else {
        showerChallenge.showerStatus = "failed";
      }
    } else {
      // Start the timer
      showerChallenge.elapsedTime = 0;
      showerChallenge.showerStatus = "in progress";
      showerChallenge.isTimerRunning = true;

      _showerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        showerChallenge.elapsedTime++;
        _saveShowerState();
        notifyListeners();
      });
    }

    await _saveShowerState();
    notifyListeners();
  }
  
  // Other methods for bike riding, car-free day, screen time, and QR code can be implemented similarly

  // Method to award points when a challenge is completed
  Future<void> completeChallenge(String challengeId, BuildContext context) async {
    final challenge = _challenges.firstWhere((c) => c.id == challengeId);
    if (!challenge.isCompleted) {
      challenge.isCompleted = true;
      
      // Award points for completing the challenge
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
      await pointsProvider.addPoints(challenge.points);
      
      // Show notification for challenge completion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge completed: ${challenge.title} (+${challenge.points} points)'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
      
      // Unlock relevant badges - pass context so badge points can be awarded
      final badgesProvider = Provider.of<BadgesProvider>(context, listen: false);
      
      // Example badge logic
      if (challengeId == 'shower' && challenge.showerStatus == 'completed') {
        await badgesProvider.unlockBadge('eco_beginner', context);
        await badgesProvider.unlockBadge('water_saver', context);
      } else if (challengeId == 'steps' && challenge.totalSteps >= 10000) {
        await badgesProvider.unlockBadge('active_walker', context);
      }
      
      notifyListeners();
    }
  }

  // Add this method to check and award points in the UI
  Future<void> checkAndAwardStepPoints(BuildContext context) async {
    if (_stepGoalAchieved) {
      // Get the completed step goal info before resetting
      final goalType = _completedStepGoal;
      
      // Reset the flag
      _stepGoalAchieved = false;
      _completedStepGoal = '';
      
      // Complete the challenge with proper ID
      await completeChallenge('steps', context);
      
      // Unlock specific badges based on the completed goal - pass context for points
      final badgesProvider = Provider.of<BadgesProvider>(context, listen: false);
      if (goalType == '5000') {
        await badgesProvider.unlockBadge('beginner_walker', context);
      } else if (goalType == '10000') {
        await badgesProvider.unlockBadge('active_walker', context);
      } else if (goalType == '20000') {
        await badgesProvider.unlockBadge('super_walker', context);
      }
    }
  }

  void _initActivityRecognition() {
    _subscribeActivityStream();
  }

  Future<bool> _checkAndRequestPermission() async {
    ActivityPermission permission =
        await FlutterActivityRecognition.instance.checkPermission();
    if (permission == ActivityPermission.PERMANENTLY_DENIED) {
      return false;
    } else if (permission == ActivityPermission.DENIED) {
      permission =
          await FlutterActivityRecognition.instance.requestPermission();
      if (permission != ActivityPermission.GRANTED) {
        return false;
      }
    }
    return true;
  }

  Future<void> _subscribeActivityStream() async {
    if (await _checkAndRequestPermission()) {
      _activitySubscription = FlutterActivityRecognition.instance.activityStream
          .handleError(_onError)
          .listen(_onActivity);
    }
  }

  void _onActivity(Activity activity) {
    if (activity.confidence == ActivityConfidence.HIGH) {
      if (activity.type == ActivityType.IN_VEHICLE) {
        final carFreeChallenge = _challenges.firstWhere((c) => c.id == 'car-free');
        carFreeChallenge.carFreeStatus = "not car-free";
        _saveChallengeState('carFreeStatus', carFreeChallenge.carFreeStatus);
        notifyListeners();
      }
      
      if (activity.type == ActivityType.ON_BICYCLE) {
        final bikeChallenge = _challenges.firstWhere((c) => c.id == 'bike');
        bikeChallenge.bikeRideStatus = "done";
        _saveChallengeState('bikeRideStatus', bikeChallenge.bikeRideStatus);
        notifyListeners();
      }
    }
  }

  void _onError(dynamic error) {
    print('Activity Recognition Error >> $error');
  }

  // Helper method to save challenge state
  Future<void> _saveChallengeState(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }
}
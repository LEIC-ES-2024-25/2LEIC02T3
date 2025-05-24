import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/challenge.dart';
import '../providers/points_provider.dart';
import '../providers/badges_provider.dart';
import '../services/notification_service.dart';
import '../services/progress_service.dart';

class ChallengesProvider with ChangeNotifier {
  late final StreamSubscription<User?> _authSubscription;
  List<Challenge> _challenges = [];
  DateTime? _lastShowerDate; // Tracks the last date the shower challenge was completed/attempted
  DateTime? _lastQRCodeDate; // Tracks the last date a QR code was scanned
  DateTime? _lastBikeDate; // Tracks the last date a bike challenge was completed
  Timer? _showerTimer;
  int _lastRecordedStepCount = 0;
  DateTime? _lastRecordedDate;
  int _totalSteps = 0; // cumulative steps since signup
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  bool _firstStepEvent = true; // skip initial sensor event to preserve saved steps
  
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
  DateTime? get lastShowerDate => _lastShowerDate; // Getter for testing or other UI needs if any
  DateTime? get lastQRCodeDate => _lastQRCodeDate; // Getter for last QR code scan date
  DateTime? get lastBikeDate => _lastBikeDate; // Getter for last bike ride date

  ChallengesProvider() {
    // Listen to auth changes to refresh or clear challenge state
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadChallengeState();
      } else {
        clearLocalChallengeProgress();
      }
    });
    _initializeChallengesBase(); // Set up the static definitions
    _loadChallengeState();     // Load dynamic state from Firestore
    _initStepCounter();
    // _initActivityRecognition(); // Commented out for now as definition is not visible/may be separate
  }
  
  // Initializes the base structure of challenges. Dynamic state is loaded by _loadChallengeState.
  void _initializeChallengesBase() {
    _challenges = [
      Challenge(id: 'steps', title: "Walk 5,000 Steps", description: "Take a walk and complete 5,000 steps today.", points: 20, totalSteps: 5000, currentSteps: 0),
      Challenge(id: 'car-free', title: "Car-Free Day", description: "Avoid using a car today.", points: 60, carFreeStatus: "car-free by now"),
      Challenge(id: 'bike', title: "Rode a Bike Today", description: "Swap your car ride for a bike ride today.", points: 30, bikeRideStatus: "not done yet"),
      Challenge(id: 'shower', title: "5-minutes-shower", description: "Take a shower in under 5 minutes.", points: 30, isTimerRunning: false, elapsedTime: 0, showerStatus: "not started"),
      Challenge(id: 'screen-time', title: "Screen Time", description: "Limit your screen time to 2 hours.", points: 80, totalSteps: 120, currentSteps: 0),
      Challenge(id: 'cleanup', title: "Attend Any Eco Event", description: "Participate in any environmental event and scan the QR code.", points: 50, qrCodeStatus: "not scanned"),
    ];
  }
  
  @override
  void dispose() {
    _authSubscription.cancel();
    _showerTimer?.cancel();
    _stepCountSubscription?.cancel();
    _activitySubscription?.cancel(); // Keep this if _initActivityRecognition is used
    super.dispose();
  }
  
  // PERSISTENCE METHODS (Firestore)
  Future<void> _loadChallengeState() async {
    // Ensure base challenges are initialized
    if (_challenges.isEmpty) _initializeChallengesBase();

    try {
      final firestoreData = await ProgressService().getUserProgress();
      if (firestoreData != null) {
        // Load last shower date
        if (firestoreData.containsKey('lastShowerDate') && firestoreData['lastShowerDate'] != null) {
          _lastShowerDate = DateTime.tryParse(firestoreData['lastShowerDate'].toString());
        } else {
          _lastShowerDate = null;
        }
        // Load last QR code scan date
        if (firestoreData.containsKey('lastQRCodeDate') && firestoreData['lastQRCodeDate'] != null) {
          _lastQRCodeDate = DateTime.tryParse(firestoreData['lastQRCodeDate'].toString());
        } else {
          _lastQRCodeDate = null;
        }
        // Load last bike ride date
        if (firestoreData.containsKey('lastBikeDate') && firestoreData['lastBikeDate'] != null) {
          _lastBikeDate = DateTime.tryParse(firestoreData['lastBikeDate'].toString());
        } else {
          _lastBikeDate = null;
        }
        // Update bike challenge status based on lastBikeDate
        final bikeChallenge = _challenges.firstWhere((c) => c.id == 'bike', orElse: () => Challenge(id:'', title:'', description:'', points:0));
        if (_lastBikeDate != null && DateTime.now().difference(_lastBikeDate!).inHours < 24) {
          bikeChallenge.isCompleted = true;
          bikeChallenge.bikeRideStatus = "completed";
        } else {
          bikeChallenge.isCompleted = false;
          bikeChallenge.bikeRideStatus = "not done yet";
        }

        // Load completed challenges
        if (firestoreData['completedChallenges'] is List) {
          final completedIds = List<String>.from(firestoreData['completedChallenges']);
          for (var challenge in _challenges) {
            // skip daily challenges
            if (challenge.id == 'shower' || challenge.id == 'bike') continue;
            challenge.isCompleted = completedIds.contains(challenge.id);
          }
        } else {
          for (var challenge in _challenges) { // Default to not completed if key missing
            if (challenge.id == 'shower' || challenge.id == 'bike') continue;
            challenge.isCompleted = false;
          }
        }

        // Load current steps for 'steps' challenge if stored
        final stepsChallenge = _challenges.firstWhere((c) => c.id == 'steps', orElse: () => Challenge(id:'', title:'', description:'', points:0)); // Dummy to avoid exception if not found
        if (stepsChallenge.id.isNotEmpty && firestoreData.containsKey('currentStepsToday')) {
            // Check if the steps are for today, otherwise reset
            if (firestoreData.containsKey('stepsDate') && firestoreData['stepsDate'] == DateTime.now().toIso8601String().substring(0,10)) {
                 stepsChallenge.currentSteps = firestoreData['currentStepsToday'] as int? ?? 0;
            } else {
                stepsChallenge.currentSteps = 0; // Stale data, reset
            }
        } else if (stepsChallenge.id.isNotEmpty) {
            stepsChallenge.currentSteps = 0; // No data, default to 0
        }
        // Load cumulative totalSteps
        if (firestoreData.containsKey('totalSteps')) {
          _totalSteps = firestoreData['totalSteps'] as int? ?? 0;
        } else {
          _totalSteps = 0;
        }

        // Load or reset QR code status after 24h
        final cleanupChallenge = _challenges.firstWhere((c) => c.id == 'cleanup', orElse: () => Challenge(id:'', title:'', description:'', points:0));
        if (cleanupChallenge.id.isNotEmpty) {
          if (_lastQRCodeDate != null && DateTime.now().difference(_lastQRCodeDate!).inHours < 24 && firestoreData.containsKey('qrCodeStatus')) {
            cleanupChallenge.qrCodeStatus = firestoreData['qrCodeStatus'] as String? ?? "not scanned";
          } else {
            cleanupChallenge.qrCodeStatus = "not scanned";
          }
        }

        // Reset baseline on load so sensor subscription calibrates properly
        _firstStepEvent = true;
      } else {
        // No data in Firestore, ensure all challenges are not completed and dynamic state is reset
        for (var challenge in _challenges) {
          // reset all, including daily ones
          challenge.isCompleted = false;
          if (challenge.id == 'steps') challenge.currentSteps = 0;
        }
        _lastShowerDate = null;
        _lastBikeDate = null;
      }
    } catch (e) {
      debugPrint('Failed to load challenge state from Firestore: $e. Initializing with default states.');
      for (var challenge in _challenges) {
        challenge.isCompleted = false;
        if (challenge.id == 'steps') challenge.currentSteps = 0;
      }
      _lastShowerDate = null;
      _lastBikeDate = null;
    }
    notifyListeners();
  }

  Future<void> _saveChallengeProgressToFirestore() async {
    try {
      // Exclude 'shower' and 'bike' (both daily) from persistent completed list
      final completedChallengeIds = _challenges
        .where((c) => c.isCompleted && c.id != 'shower' && c.id != 'bike')
        .map((c) => c.id)
        .toList();
      final stepsChallenge = _challenges.firstWhere((c) => c.id == 'steps');
      final cleanupChallenge = _challenges.firstWhere((c) => c.id == 'cleanup');
      
      Map<String, dynamic> progressData = {
        'completedChallenges': completedChallengeIds,
        'currentStepsToday': stepsChallenge.currentSteps,
        'stepsDate': DateTime.now().toIso8601String().substring(0,10),
        'totalSteps': _totalSteps, // persist cumulative steps
        'qrCodeStatus': cleanupChallenge.qrCodeStatus, // Save QR code status
      };
      if (_lastShowerDate != null) {
        progressData['lastShowerDate'] = _lastShowerDate!.toIso8601String();
      } else {
        progressData['lastShowerDate'] = null;
      }
      // Save last QR code scan date
      if (_lastQRCodeDate != null) {
        progressData['lastQRCodeDate'] = _lastQRCodeDate!.toIso8601String();
      } else {
        progressData['lastQRCodeDate'] = null;
      }
      // Save last bike ride date
      if (_lastBikeDate != null) {
        progressData['lastBikeDate'] = _lastBikeDate!.toIso8601String();
      } else {
        progressData['lastBikeDate'] = null;
      }
      await ProgressService().setUserProgress(progressData);
    } catch (e) {
      debugPrint('Failed to save challenge progress to Firestore: $e');
    }
  }
  
  // STEP COUNTER METHODS
  void _initStepCounter() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountSubscription = _stepCountStream?.listen(_onStepCount, onError: (error) {
      debugPrint("Pedometer error: $error");
    });
  }
  
  void _onStepCount(StepCount event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final stepsChallenge = _challenges.firstWhere((c) => c.id == 'steps');

    // Calibrate baseline without resetting saved steps
    if (_firstStepEvent) {
      int baseline;
      if (_lastRecordedDate != null && _lastRecordedDate!.isAtSameMomentAs(today)) {
        baseline = event.steps - stepsChallenge.currentSteps;
      } else {
        baseline = event.steps;
      }
      _lastRecordedStepCount = baseline;
      _lastRecordedDate = today;
      _firstStepEvent = false;
      return;
    }

    // Normal delta logic
    if (_lastRecordedDate == null || !_lastRecordedDate!.isAtSameMomentAs(today)) {
      // New day or first time, reset daily step count based on this event
      _lastRecordedStepCount = event.steps; // This is the total steps from the sensor since reboot
      _lastRecordedDate = today;
      stepsChallenge.currentSteps = 0; // Reset for the new day, will be updated below
    }
    
    // Calculate steps taken today
    // Pedometer gives total steps since device reboot or app install.
    // We need to track the delta from the start of the day or session.
    int currentSensorSteps = event.steps;
    int stepsToday = currentSensorSteps - _lastRecordedStepCount;
    // update cumulative totalSteps by delta since last update
    final prevToday = _challenges.firstWhere((c) => c.id == 'steps').currentSteps;
    final delta = stepsToday - prevToday;
    if (delta > 0) {
      _totalSteps += delta;
    }

    stepsChallenge.currentSteps = stepsToday;

    // Update the background notification with current steps
    NotificationService().showStepCountNotification(stepsChallenge.currentSteps);
    
    // Auto-completion logic for step challenge (optional, can be UI driven)
    // if (stepsChallenge.currentSteps >= stepsChallenge.totalSteps && !stepsChallenge.isCompleted) {
    //    completeChallenge(stepsChallenge.id, null); // Requires BuildContext or context-less version
    // }

    _saveChallengeProgressToFirestore(); // Save step progress
    notifyListeners();
  }
  
  // SHOWER METHODS
  void toggleShowerTimer(BuildContext context) async {
    // Refresh lastShowerDate directly from Firestore to enforce cooldown
    final firestoreData = await ProgressService().getUserProgress();
    DateTime? lastDateDb;
    if (firestoreData != null && firestoreData['lastShowerDate'] != null) {
      lastDateDb = DateTime.tryParse(firestoreData['lastShowerDate'].toString());
    }
    if (lastDateDb != null && DateTime.now().difference(lastDateDb).inHours < 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can only take the 5-minute shower challenge once per day"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    // Set local date to keep sync
    _lastShowerDate = lastDateDb;
    final showerChallenge = _challenges.firstWhere((c) => c.id == 'shower');
    if (showerChallenge.isTimerRunning) {
      _showerTimer?.cancel();
      showerChallenge.isTimerRunning = false;

      debugPrint("Shower elapsed time: ${showerChallenge.elapsedTime} seconds");

      await _markShowerChallengeUsedToday(); // Mark as used regardless of success/failure for the day

      if (showerChallenge.elapsedTime < 300) { // 5 minutes
        showerChallenge.showerStatus = "completed";
        // completeChallenge will also call _saveChallengeProgressToFirestore
        await completeChallenge('shower', context); 
      } else {
        showerChallenge.showerStatus = "failed";
        // Even if failed, the progress (including the new _lastShowerDate) should be saved.
        await _saveChallengeProgressToFirestore(); 
      }
    } else {
      // Start the timer
      showerChallenge.elapsedTime = 0;
      showerChallenge.showerStatus = "in progress";
      showerChallenge.isTimerRunning = true;

      _showerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        showerChallenge.elapsedTime++;
        if (showerChallenge.elapsedTime >= 300 && showerChallenge.isTimerRunning) { // Auto-stop if exceeds 5 mins
            // This part handles auto-fail if timer runs too long without manual stop
            // toggleShowerTimer(context); // This would call it again, leading to _markShowerChallengeUsedToday
            // Let's ensure it's marked and saved if it auto-fails here
            if (showerChallenge.isTimerRunning) { // Check again in case it was stopped manually right at 300s
                _showerTimer?.cancel();
                showerChallenge.isTimerRunning = false;
                showerChallenge.showerStatus = "failed";
                debugPrint("Shower auto-failed after 300 seconds.");
                _markShowerChallengeUsedToday().then((_) => notifyListeners()); // Mark used and save
            }
        } else {
            notifyListeners();
        }
      });
    }
    notifyListeners();
  }
  
  // Helper: mark shower challenge used today and persist
  Future<void> _markShowerChallengeUsedToday() async {
    _lastShowerDate = DateTime.now();
    await _saveChallengeProgressToFirestore();
  }

  // BIKE CHALLENGE METHODS
  /// Public: complete the bike challenge once per day
  Future<void> completeBikeChallenge(BuildContext context) async {
    // Use local _lastBikeDate to enforce a 24h cooldown
    final now = DateTime.now();
    if (_lastBikeDate != null && now.difference(_lastBikeDate!).inHours < 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can only complete the bike challenge once per day"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }
    // Mark as used and persist
    _lastBikeDate = now;
    await _saveChallengeProgressToFirestore();
     // Update challenge status
     final bikeChallenge = _challenges.firstWhere((c) => c.id == 'bike');
     bikeChallenge.bikeRideStatus = "completed";
     // Award points and badges
     await completeChallenge('bike', context);
     notifyListeners();
   }
  
  // Method to award points when a challenge is completed
  Future<void> completeChallenge(String challengeId, BuildContext context) async {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1 && !_challenges[challengeIndex].isCompleted) {
      _challenges[challengeIndex].isCompleted = true;
      
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
      await pointsProvider.addPoints(_challenges[challengeIndex].points);
      
      await _saveChallengeProgressToFirestore();
      // Unlock badge corresponding to this challenge
      try {
        final badgesProvider = Provider.of<BadgesProvider>(context, listen: false);
        String? badgeId;
        switch (challengeId) {
          case 'steps': badgeId = 'step_enthusiast'; break;
          case 'shower': badgeId = 'water_saver'; break;
          case 'bike': badgeId = 'cycling_pro'; break;
          case 'cleanup': badgeId = 'community_leader'; break;
          case 'screen-time': badgeId = 'screen_balancer'; break;
        }
        if (badgeId != null) {
          await badgesProvider.unlockBadge(badgeId, context);
          // Unlock 'Eco Beginner' on first badge completion
          final firstBadge = 'eco_beginner';
          if (!badgesProvider.badges.any((b) => b.id == firstBadge && b.isUnlocked)) {
            await badgesProvider.unlockBadge(firstBadge, context);
          }
          // Unlock 'Eco Master' when all other badges are unlocked
          final allBadgeIds = ['eco_beginner','step_enthusiast','water_saver','screen_balancer','cycling_pro','community_leader'];
          final unlockedIds = badgesProvider.badges.where((b) => b.isUnlocked).map((b) => b.id).toList();
          if (!unlockedIds.contains('eco_master') && allBadgeIds.every((id) => unlockedIds.contains(id))) {
            await badgesProvider.unlockBadge('eco_master', context);
          }
        }
      } catch (_) {}
      notifyListeners();
    }
  }
  
  // This method is kept if direct manipulation of _lastShowerDate and saving is needed elsewhere,
  // but _markShowerChallengeUsedToday is preferred for the shower challenge flow.
  Future<void> setLastShowerDate(DateTime date) async {
    _lastShowerDate = date;
    await _saveChallengeProgressToFirestore();
    notifyListeners();
  }

  // Public: check if QR code has been scanned today
  Future<bool> hasQRCodeBeenScannedToday() async {
    if (_lastQRCodeDate == null) return false;
    final now = DateTime.now();
    return _lastQRCodeDate!.year == now.year &&
           _lastQRCodeDate!.month == now.month &&
           _lastQRCodeDate!.day == now.day;
  }

  // Public: mark QR code as scanned today
  Future<void> markQRCodeScannedToday() async {
    _lastQRCodeDate = DateTime.now();
    await _saveChallengeProgressToFirestore();
  }

  Future<void> clearLocalChallengeProgress() async {
    _initializeChallengesBase();
    _lastShowerDate = null;
    _lastQRCodeDate = null;
    _lastBikeDate = null;
    _lastRecordedStepCount = 0;
    _lastRecordedDate = null; 

    _showerTimer?.cancel();
    _showerTimer = null; 

    // Ensure all challenge-specific dynamic states within the objects are reset
    for (var challenge in _challenges) {
        challenge.isCompleted = false; // Already done by _initializeChallengesBase if it creates new objects
                                     // but good to be explicit if it modifies existing ones.
        challenge.currentSteps = 0; 
        if (challenge.id == 'shower') {
            challenge.isTimerRunning = false;
            challenge.elapsedTime = 0;
            challenge.showerStatus = "not started";
        }
        // Reset other challenge-specific statuses if any
        if (challenge.id == 'car-free') challenge.carFreeStatus = "car-free by now"; // Default
        if (challenge.id == 'bike') challenge.bikeRideStatus = "not done yet"; // Default bike status
        if (challenge.id == 'cleanup') challenge.qrCodeStatus = "not scanned"; // Default
    }

    notifyListeners();
  }

  // Placeholder for activity recognition initialization - implement if needed
  // void _initActivityRecognition() {
  //   // ... implementation ...
  //   // _activitySubscription = FlutterActivityRecognition.activityStream.listen((Activity activity) {
  //   //   // Process activity updates
  //   // });
  // }

  // Method to update the QR code status for the cleanup challenge
  Future<void> updateQRCodeStatus(String eventType) async {
    final cleanupChallenge = _challenges.firstWhere((c) => c.id == 'cleanup', orElse: () => Challenge(id: '', title: '', description: '', points: 0));
    if (cleanupChallenge.id.isNotEmpty) {
      cleanupChallenge.qrCodeStatus = "Scanned: $eventType";
      // mark daily scan
      await markQRCodeScannedToday();
      await _saveChallengeProgressToFirestore();
      notifyListeners();
    }
  }
}
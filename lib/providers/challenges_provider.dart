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
  DateTime? _lastShowerDate; 
  DateTime? _lastQRCodeDate; 
  DateTime? _lastBikeDate; 
  Timer? _showerTimer;
  int _lastRecordedStepCount = 0;
  DateTime? _lastRecordedDate;
  int _totalSteps = 0; 
  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;
  bool _firstStepEvent = true; 
  
  
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
  DateTime? get lastShowerDate => _lastShowerDate; 
  DateTime? get lastQRCodeDate => _lastQRCodeDate; 
  DateTime? get lastBikeDate => _lastBikeDate; 

  ChallengesProvider() {
    
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _loadChallengeState();
      } else {
        clearLocalChallengeProgress();
      }
    });
    _initializeChallengesBase(); 
    _loadChallengeState();     
    _initStepCounter();
    
  }
  
  
  void _initializeChallengesBase() {
    _challenges = [
      Challenge(id: 'steps', title: "Walk 5,000 Steps", description: "Take a walk and complete 5,000 steps today.", points: 20, totalSteps: 5000, currentSteps: 0),
      Challenge(id: 'car-free', title: "Car-Free Day", description: "Avoid using a car today.", points: 60, carFreeStatus: "car-free by now"),
      Challenge(id: 'bike', title: "Rode a Bike Today", description: "Swap your car ride for a bike ride today.", points: 30, bikeRideStatus: "not done yet"),
      Challenge(id: 'shower', title: "5-minutes-shower", description: "Take a shower in under 5 minutes.", points: 30, isTimerRunning: false, elapsedTime: 0, showerStatus: "not started"),
      Challenge(id: 'cleanup', title: "Attend Any Eco Event", description: "Participate in any environmental event and scan the QR code.", points: 50, qrCodeStatus: "not scanned"),
    ];
  }
  
  @override
  void dispose() {
    _authSubscription.cancel();
    _showerTimer?.cancel();
    _stepCountSubscription?.cancel();
    _activitySubscription?.cancel(); 
    super.dispose();
  }
  
  
  Future<void> _loadChallengeState() async {
    
    if (_challenges.isEmpty) _initializeChallengesBase();

    try {
      final firestoreData = await ProgressService().getUserProgress();
      if (firestoreData != null) {
        
        if (firestoreData.containsKey('lastShowerDate') && firestoreData['lastShowerDate'] != null) {
          _lastShowerDate = DateTime.tryParse(firestoreData['lastShowerDate'].toString());
        } else {
          _lastShowerDate = null;
        }
        
        if (firestoreData.containsKey('lastQRCodeDate') && firestoreData['lastQRCodeDate'] != null) {
          _lastQRCodeDate = DateTime.tryParse(firestoreData['lastQRCodeDate'].toString());
        } else {
          _lastQRCodeDate = null;
        }
        
        if (firestoreData.containsKey('lastBikeDate') && firestoreData['lastBikeDate'] != null) {
          _lastBikeDate = DateTime.tryParse(firestoreData['lastBikeDate'].toString());
        } else {
          _lastBikeDate = null;
        }
        
        final bikeChallenge = _challenges.firstWhere((c) => c.id == 'bike', orElse: () => Challenge(id:'', title:'', description:'', points:0));
        if (_lastBikeDate != null && DateTime.now().difference(_lastBikeDate!).inHours < 24) {
          bikeChallenge.isCompleted = true;
          bikeChallenge.bikeRideStatus = "completed";
        } else {
          bikeChallenge.isCompleted = false;
          bikeChallenge.bikeRideStatus = "not done yet";
        }

        
        if (firestoreData['completedChallenges'] is List) {
          final completedIds = List<String>.from(firestoreData['completedChallenges']);
          for (var challenge in _challenges) {
            
            if (challenge.id == 'shower' || challenge.id == 'bike') continue;
            challenge.isCompleted = completedIds.contains(challenge.id);
          }
        } else {
          for (var challenge in _challenges) { 
            if (challenge.id == 'shower' || challenge.id == 'bike') continue;
            challenge.isCompleted = false;
          }
        }

        
        final stepsChallenge = _challenges.firstWhere((c) => c.id == 'steps', orElse: () => Challenge(id:'', title:'', description:'', points:0)); 
        if (stepsChallenge.id.isNotEmpty && firestoreData.containsKey('currentStepsToday')) {
            
            if (firestoreData.containsKey('stepsDate') && firestoreData['stepsDate'] == DateTime.now().toIso8601String().substring(0,10)) {
                 stepsChallenge.currentSteps = firestoreData['currentStepsToday'] as int? ?? 0;
            } else {
                stepsChallenge.currentSteps = 0; 
            }
        } else if (stepsChallenge.id.isNotEmpty) {
            stepsChallenge.currentSteps = 0; 
        }
        
        if (firestoreData.containsKey('totalSteps')) {
          _totalSteps = firestoreData['totalSteps'] as int? ?? 0;
        } else {
          _totalSteps = 0;
        }

        
        final cleanupChallenge = _challenges.firstWhere((c) => c.id == 'cleanup', orElse: () => Challenge(id:'', title:'', description:'', points:0));
        if (cleanupChallenge.id.isNotEmpty) {
          if (_lastQRCodeDate != null && DateTime.now().difference(_lastQRCodeDate!).inHours < 24 && firestoreData.containsKey('qrCodeStatus')) {
            cleanupChallenge.qrCodeStatus = firestoreData['qrCodeStatus'] as String? ?? "not scanned";
            cleanupChallenge.isCompleted = true; 
          } else {
            cleanupChallenge.qrCodeStatus = "not scanned";
            cleanupChallenge.isCompleted = false; 
          }
        }

        
        _firstStepEvent = true;
      } else {
        
        for (var challenge in _challenges) {
          
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
        'totalSteps': _totalSteps, 
        'qrCodeStatus': cleanupChallenge.qrCodeStatus, 
      };
      if (_lastShowerDate != null) {
        progressData['lastShowerDate'] = _lastShowerDate!.toIso8601String();
      } else {
        progressData['lastShowerDate'] = null;
      }
      
      if (_lastQRCodeDate != null) {
        progressData['lastQRCodeDate'] = _lastQRCodeDate!.toIso8601String();
      } else {
        progressData['lastQRCodeDate'] = null;
      }
      
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

    
    if (_lastRecordedDate == null || !_lastRecordedDate!.isAtSameMomentAs(today)) {
      
      _lastRecordedStepCount = event.steps; 
      _lastRecordedDate = today;
      stepsChallenge.currentSteps = 0; 
    }
    
    
    
    
    int currentSensorSteps = event.steps;
    int stepsToday = currentSensorSteps - _lastRecordedStepCount;
    
    final prevToday = _challenges.firstWhere((c) => c.id == 'steps').currentSteps;
    final delta = stepsToday - prevToday;
    if (delta > 0) {
      _totalSteps += delta;
    }

    stepsChallenge.currentSteps = stepsToday;

    
    NotificationService().showStepCountNotification(stepsChallenge.currentSteps);
    
    
    
    
    

    _saveChallengeProgressToFirestore(); 
    notifyListeners();
  }
  
  
  void toggleShowerTimer(BuildContext context) async {
    
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
    
    _lastShowerDate = lastDateDb;
    final showerChallenge = _challenges.firstWhere((c) => c.id == 'shower');
    if (showerChallenge.isTimerRunning) {
      _showerTimer?.cancel();
      showerChallenge.isTimerRunning = false;

      debugPrint("Shower elapsed time: ${showerChallenge.elapsedTime} seconds");

      await _markShowerChallengeUsedToday(); 

      if (showerChallenge.elapsedTime < 300) { 
        showerChallenge.showerStatus = "completed";
        
        await completeChallenge('shower', context); 
      } else {
        showerChallenge.showerStatus = "failed";
        
        await _saveChallengeProgressToFirestore(); 
      }
    } else {
      
      showerChallenge.elapsedTime = 0;
      showerChallenge.showerStatus = "in progress";
      showerChallenge.isTimerRunning = true;

      _showerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        showerChallenge.elapsedTime++;
        if (showerChallenge.elapsedTime >= 300 && showerChallenge.isTimerRunning) { 
            
            
            
            if (showerChallenge.isTimerRunning) { 
                _showerTimer?.cancel();
                showerChallenge.isTimerRunning = false;
                showerChallenge.showerStatus = "failed";
                debugPrint("Shower auto-failed after 300 seconds.");
                _markShowerChallengeUsedToday().then((_) => notifyListeners()); 
            }
        } else {
            notifyListeners();
        }
      });
    }
    notifyListeners();
  }
  
  
  Future<void> _markShowerChallengeUsedToday() async {
    _lastShowerDate = DateTime.now();
    await _saveChallengeProgressToFirestore();
  }

  
  
  Future<void> completeBikeChallenge(BuildContext context) async {
    
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
    
    _lastBikeDate = now;
    await _saveChallengeProgressToFirestore();
     
     final bikeChallenge = _challenges.firstWhere((c) => c.id == 'bike');
     bikeChallenge.bikeRideStatus = "completed";
     
     await completeChallenge('bike', context);
     notifyListeners();
   }
  
  
  Future<void> completeChallenge(String challengeId, BuildContext context) async {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1 && !_challenges[challengeIndex].isCompleted) {
      _challenges[challengeIndex].isCompleted = true;
      
      final pointsProvider = Provider.of<PointsProvider>(context, listen: false);
      final challengePoints = _challenges[challengeIndex].points;
      final challengeTitle = _challenges[challengeIndex].title;
      await pointsProvider.addPoints(challengePoints);
      
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Challenge completed +${challengePoints} points!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      
      await NotificationService().showChallengeCompletedNotification(
        challengeTitle,
        challengePoints
      );
      
      await _saveChallengeProgressToFirestore();
      
      try {
        final badgesProvider = Provider.of<BadgesProvider>(context, listen: false);
        String? badgeId;
        switch (challengeId) {
          case 'steps': badgeId = 'step_enthusiast'; break;
          case 'shower': badgeId = 'water_saver'; break;
          case 'bike': badgeId = 'cycling_pro'; break;
          case 'cleanup': badgeId = 'community_leader'; break;
        }
        if (badgeId != null) {
          await badgesProvider.unlockBadge(badgeId, context);
          
          final firstBadge = 'eco_beginner';
          if (!badgesProvider.badges.any((b) => b.id == firstBadge && b.isUnlocked)) {
            await badgesProvider.unlockBadge(firstBadge, context);
          }
          
          final allBadgeIds = ['eco_beginner','step_enthusiast','water_saver','cycling_pro','community_leader'];
          final unlockedIds = badgesProvider.badges.where((b) => b.isUnlocked).map((b) => b.id).toList();
          if (!unlockedIds.contains('eco_master') && allBadgeIds.every((id) => unlockedIds.contains(id))) {
            await badgesProvider.unlockBadge('eco_master', context);
          }
        }
      } catch (_) {}
      notifyListeners();
    }
  }
  
  
  
  Future<void> setLastShowerDate(DateTime date) async {
    _lastShowerDate = date;
    await _saveChallengeProgressToFirestore();
    notifyListeners();
  }

  
  Future<bool> hasQRCodeBeenScannedToday() async {
    if (_lastQRCodeDate == null) return false;
    final now = DateTime.now();
    return _lastQRCodeDate!.year == now.year &&
           _lastQRCodeDate!.month == now.month &&
           _lastQRCodeDate!.day == now.day;
  }

  
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

    
    for (var challenge in _challenges) {
        challenge.isCompleted = false; 
                                     
        challenge.currentSteps = 0; 
        if (challenge.id == 'shower') {
            challenge.isTimerRunning = false;
            challenge.elapsedTime = 0;
            challenge.showerStatus = "not started";
        }
        
        if (challenge.id == 'car-free') challenge.carFreeStatus = "car-free by now"; 
        if (challenge.id == 'bike') challenge.bikeRideStatus = "not done yet"; 
        if (challenge.id == 'cleanup') challenge.qrCodeStatus = "not scanned"; 
    }

    notifyListeners();
  }

  
  
  
  
  
  
  

  
  Future<void> updateQRCodeStatus(String eventType) async {
    final cleanupChallenge = _challenges.firstWhere((c) => c.id == 'cleanup', orElse: () => Challenge(id: '', title: '', description: '', points: 0));
    if (cleanupChallenge.id.isNotEmpty) {
      cleanupChallenge.qrCodeStatus = "Scanned: $eventType";
      
      await markQRCodeScannedToday();
      await _saveChallengeProgressToFirestore();
      notifyListeners();
    }
  }
}
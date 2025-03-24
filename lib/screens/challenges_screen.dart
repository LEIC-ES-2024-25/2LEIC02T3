import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:app_usage/app_usage.dart'; // Import the app_usage package
import 'package:mobile_scanner/mobile_scanner.dart'; // Import mobile_scanner for QR code scanning
import '../models/challenge.dart';
import 'bottom_navigation_bar.dart';

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
    Challenge(
      title: "Car-Free Day",
      description: "Avoid using a car today.",
      points: 60,
      carFreeStatus: "car-free by now",
    ),
    Challenge(
      title: "Rode a Bike Today",
      description: "Swap your car ride for a bike ride today.",
      points: 30,
      bikeRideStatus: "not done yet",
    ),
    Challenge(
      title: "5-minutes-shower",
      description: "Take a shower in under 5 minutes.",
      points: 30,
      isTimerRunning: false,
      elapsedTime: 0,
      showerStatus: "not started",
    ),
    Challenge(
      title: "Screen Time",
      description: "Limit your screen time to 2 hours.",
      points: 80,
      totalSteps: 120,
      // 2 hours
      currentSteps: 0, // Track screen time
    ),
    Challenge(
      title: "Go to Clean-up Event",
      description: "Participate in a clean-up event today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Go to Eco-friendly Market",
      description: "Visit an eco-friendly market today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Go to Sustainable Food Festival",
      description: "Attend a sustainable food festival today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Go to Tree Planting Event",
      description: "Attend a tree planting event today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Go to Bicycle Parade",
      description: "Attend a bicycle parade today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Go to Group Walk Event",
      description: "Join a group walk event today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Play a Sport Event",
      description: "Participate in a sport event today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Go to Car-free Day Meet-up",
      description: "Join a car-free day meet-up today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Join a Car Pool",
      description: "Share a ride by joining a car pool today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Support Local Commerce",
      description: "Shop at a local commerce store today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Go to Thrift Store",
      description: "Visit a thrift store today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
    Challenge(
      title: "Use Public Transport",
      description: "Take public transport today.",
      points: 50,
      qrCodeStatus: "not scanned", // New property for QR code status
    ),
  ];

  //----------------------------------------------------------------------------
  //trackers and timers----------------------------------------------------------------------------

  StreamSubscription<StepCount>? _stepCountStream;
  int _lastRecordedStepCount = 0; // Tracks the step count at the start of the day
  DateTime? _lastRecordedDate; // Tracks the last recorded date
  StreamSubscription<Activity>? _activitySubscription;
  Timer? _showerTimer;
  Timer? _screenTimeUpdateTimer;

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
  //activity recognition----------------------------------------------------------------------------

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
    setState(() {
      if (activity.confidence == ActivityConfidence.HIGH) {
        if (activity.type == ActivityType.WALKING) {
          challenges[1].carFreeStatus = "not-car-free";
        }
        if (activity.type == ActivityType.ON_BICYCLE) {
          challenges[2].bikeRideStatus = "done";
        }
      }
    });
  }

  void _onError(dynamic error) {
    print('Error >> $error');
  }

  //----------------------------------------------------------------------------
  //shower timer----------------------------------------------------------------------------

  // Add a new method to check if the shower challenge has been used today
  Future<bool> _hasShowerChallengeBeenUsedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShowerDate = prefs.getString('lastShowerDate');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastShowerDate == null) {
      return false; // No record of usage yet
    }

    final lastDate = DateTime.tryParse(lastShowerDate);
    if (lastDate == null) {
      return false; // Invalid date stored
    }

    // Check if the last usage was today
    return lastDate.isAtSameMomentAs(today);
  }

  Future<void> _loadShowerState() async {
    final prefs = await SharedPreferences.getInstance();
    final elapsedTime = prefs.getInt('showerElapsedTime') ?? 0;
    final showerStatus = prefs.getString('showerStatus') ?? "not started";

    setState(() {
      challenges[3].elapsedTime =
          elapsedTime; // Assuming "5-minutes-shower" is at index 3
      challenges[3].showerStatus = showerStatus;
      challenges[3].isTimerRunning =
      false; // Ensure the timer is not running on app start
    });
  }

// Update the shower timer logic to include the daily restriction
  void _toggleShowerTimer(int index) async {
    // Check if the shower challenge has already been used today
    final hasBeenUsedToday = await _hasShowerChallengeBeenUsedToday();
    if (hasBeenUsedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            "You can only take the 5-minute shower challenge once per day!")),
      );
      return;
    }

    setState(() {
      final challenge = challenges[index];
      if (challenge.isTimerRunning) {
        _showerTimer?.cancel();
        challenge.isTimerRunning = false;

        // Determine the shower status based on elapsed time
        if (challenge.elapsedTime < 120) {
          challenge.showerStatus = "still a little dirty, no?";
        } else if (challenge.elapsedTime < 300) {
          challenge.showerStatus = "quick-shower";
        } else {
          challenge.showerStatus = "long-shower";
        }

        // Save the current date as the last shower date
        _saveLastShowerDate();

        // Save the shower state (elapsed time and status)
        _saveShowerState(challenge.elapsedTime, challenge.showerStatus);
      } else {
        challenge.isTimerRunning = true;
        challenge.elapsedTime = 0;
        challenge.showerStatus = "in progress";

        _showerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (challenges[index].isTimerRunning) {
              challenges[index].elapsedTime++;
            } else {
              timer.cancel();
            }
          });
        });
      }
    });
  }

// Method to save the last shower date
  Future<void> _saveLastShowerDate() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await prefs.setString('lastShowerDate', today.toString());
  }

  Future<void> _saveShowerState(int elapsedTime, String showerStatus) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('showerElapsedTime', elapsedTime);
    await prefs.setString('showerStatus', showerStatus);
  }

  //----------------------------------------------------------------------------
  //screen time----------------------------------------------------------------------------

  // Function to fetch and calculate total screen time
  Future<void> getTotalScreenTime() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(hours: 2, minutes: 53));
      // DateTime startDate = endDate.subtract(Duration(days: 0, hours: DateTime.now().hour, minutes: DateTime.now().minute, seconds: DateTime.now().second));
      // DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(
          startDate, endDate);

      int totalMinutes = 0;
      for (var appUsage in infoList) {
        totalMinutes +=
            appUsage.usage.inMinutes; // Sum up usage time in minutes
      }

      setState(() {
        // Update the "Screen Time" challenge's currentSteps with the total screen time
        challenges[4].currentSteps =
            totalMinutes; // Assuming "Screen Time" is at index 6
      });
    } catch (exception) {
      print("Error fetching screen time: $exception");
    }
  }

  //----------------------------------------------------------------------------
  //qr code scanner----------------------------------------------------------------------------

  Future<bool> _hasQRChallengeBeenUsedToday(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final lastScanDate = prefs.getString(key);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastScanDate == null) {
      return false; // No record of usage yet
    }

    final lastDate = DateTime.tryParse(lastScanDate);
    if (lastDate == null) {
      return false; // Invalid date stored
    }

    // Check if the last usage was today
    return lastDate.isAtSameMomentAs(today);
  }

  Future<void> _loadQRChallengeStates() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      for (var challenge in challenges) {
        if (challenge.title == "Go to Clean-up Event" ||
            challenge.title == "Go to Eco-friendly Market" ||
            challenge.title == "Go to Sustainable Food Festival" ||
            challenge.title == "Go to Tree Planting Event" ||
            challenge.title == "Go to Bicycle Parade" ||
            challenge.title == "Go to Group Walk Event" ||
            challenge.title == "Play a Sport Event" ||
            challenge.title == "Go to Car-free Day Meet-up" ||
            challenge.title == "Join a Car Pool" ||
            challenge.title == "Support Local Commerce" ||
            challenge.title == "Go to Thrift Store" ||
            challenge.title == "Use Public Transport") {
          final key = 'lastQRScan_${challenge.title}';
          final lastScanDate = prefs.getString(key);

          if (lastScanDate != null) {
            final lastDate = DateTime.tryParse(lastScanDate);
            final today = DateTime.now();

            // If the last scan was today, mark the challenge as "scanned"
            if (lastDate != null &&
                lastDate.year == today.year &&
                lastDate.month == today.month &&
                lastDate.day == today.day) {
              challenge.qrCodeStatus = "scanned";
            } else {
              challenge.qrCodeStatus = "not scanned"; // Reset if it's not today
            }
          }
        }
      }
    });
  }

  Future<void> _saveLastQRScanDate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    await prefs.setString(key, today.toString());
  }

  bool validateQRCode(String qrCode, String eventType) {
    try {
      // Split the QR code into parts
      List<String> parts = qrCode.split(' ');
      if (parts.length != 2) return false;

      String eventPart = parts[0];
      String datePart = parts[1];

      // Check if the event type matches
      if (eventPart != eventType) return false;

      // Check if it matches today's date
      List<String> dateParts = datePart.split('-');
      if (dateParts.length != 3)
        return false; // Ensure the date is properly formatted

      int year = int.parse(dateParts[0]);
      int month = int.parse(dateParts[1]);
      int day = int.parse(dateParts[2]);

      // Create a DateTime object for the QR code date
      DateTime qrDate = DateTime(year, month, day);

      // Get today's date
      DateTime today = DateTime.now();

      // Compare the dates (ignoring time)
      if (qrDate.year != today.year || qrDate.month != today.month ||
          qrDate.day != today.day) {
        return false;
      }

      return true;
    } catch (e) {
      return false; // Invalid format or parsing error
    }
  }

  Future<void> _scanQRCode(int index) async {
    final challenge = challenges[index];
    final prefsKey = 'lastQRScan_${challenge
        .title}'; // Unique key for each challenge

    // Check if the challenge has already been used today
    final hasBeenUsedToday = await _hasQRChallengeBeenUsedToday(prefsKey);
    if (hasBeenUsedToday) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
            "You can only complete this challenge once per day!")),
      );
      return;
    }

    final scannerController = MobileScannerController();
    String? qrCodeResult;

    // Navigate to a temporary screen for scanning
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            Scaffold(
              appBar: AppBar(title: const Text('Scan QR Code')),
              body: Column(
                children: [
                  Expanded(
                    child: MobileScanner(
                      controller: scannerController,
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        for (final barcode in barcodes) {
                          if (barcode.rawValue != null) {
                            qrCodeResult = barcode.rawValue!;
                            scannerController
                                .stop(); // Stop scanning after detecting a QR code
                            Navigator.pop(
                                context); // Return to ChallengesScreen
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
      ),
    );

    // Validate the QR code after returning from the scanner
    if (qrCodeResult != null) {
      final challenge = challenges[index];
      String eventType = '';

      // Determine the expected event type based on the challenge title
      if (challenge.title == "Go to Clean-up Event") {
        eventType = 'clean|up|event';
      } else if (challenge.title == "Go to Eco-friendly Market") {
        eventType = 'eco|friendly|market';
      } else if (challenge.title == "Go to Sustainable Food Festival") {
        eventType = 'sustainable|food|festival';
      } else if (challenge.title == "Go to Tree Planting Event") {
        eventType = 'tree|planting|event';
      } else if (challenge.title == "Go to Bicycle Parade") {
        eventType = 'bicycle|parade';
      } else if (challenge.title == "Go to Group Walk Event") {
        eventType = 'group|walk|event';
      } else if (challenge.title == "Play a Sport Event") {
        eventType = 'play|a|sport|event';
      } else if (challenge.title == "Go to Car-free Day Meet-up") {
        eventType = 'car|free|day|meet|up';
      } else if (challenge.title == "Join a Car Pool") {
        eventType = 'car|pool';
      } else if (challenge.title == "Support Local Commerce") {
        eventType = 'local|commerce';
      } else if (challenge.title == "Go to Thrift Store") {
        eventType = 'thrift|store';
      } else if (challenge.title == "Use Public Transport") {
        eventType = 'public|transport';
      }

      // Validate the QR code
      if (validateQRCode(qrCodeResult!, eventType)) {
        setState(() {
          challenge.qrCodeStatus = "scanned";
        });

        // Save the last scan date
        await _saveLastQRScanDate(prefsKey);

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("QR Code Validated!")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid QR Code!")));
      }
    }
  }


  //----------------------------------------------------------------------------
  //initState & dispose----------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    // Load saved data (including last shower date)
    _loadSavedData().then((_) {
      _startListeningToSteps();
    });

    _loadShowerState();
    _loadQRChallengeStates(); // Load QR challenge states

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Challenges'),
          backgroundColor: Colors.green.shade800,
        titleTextStyle: TextStyle(
          color: Colors.white, // Set the header text color to white
          fontSize: 20, // Optional: Adjust font size if needed
          fontWeight: FontWeight.bold, // Optional: Make the text bold
        ),
      ),
      backgroundColor: Colors.green.shade100,
      body: ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Points
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${challenge.points} Points',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    challenge.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  // Status or Progress Bar
                  if (challenge.totalSteps == 5000 ||
                      challenge.totalSteps == 10000 ||
                      challenge.totalSteps == 20000 ||
                      challenge.totalSteps == 50000)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: challenge.currentSteps / challenge.totalSteps,
                          backgroundColor: Colors.grey[300],
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${challenge.currentSteps} / ${challenge.totalSteps} steps",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                  else if (challenge.totalSteps == 120)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: challenge.currentSteps / challenge.totalSteps,
                          backgroundColor: Colors.grey[300],
                          color: challenge.currentSteps > challenge.totalSteps
                              ? Colors.red // Turn red if current steps exceed total steps
                              : Colors.green, // Otherwise, keep it green
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${challenge.currentSteps} / ${challenge.totalSteps} minutes",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                  else
                    if (challenge.title == "Car-Free Day")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status: ${challenge.carFreeStatus}",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      )
                    else
                      if (challenge.title == "Rode a Bike Today")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Status: ${challenge.bikeRideStatus}",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        )
                      else
                        if (challenge.title == "Go to Clean-up Event" ||
                            challenge.title == "Go to Eco-friendly Market" ||
                            challenge.title == "Go to Sustainable Food Festival" ||
                            challenge.title == "Go to Tree Planting Event" ||
                            challenge.title == "Go to Bicycle Parade" ||
                            challenge.title == "Go to Group Walk Event" ||
                            challenge.title == "Play a Sport Event" ||
                            challenge.title == "Go to Car-free Day Meet-up" ||
                            challenge.title == "Join a Car Pool" ||
                            challenge.title == "Support Local Commerce" ||
                            challenge.title == "Go to Thrift Store" ||
                            challenge.title == "Use Public Transport")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("QR Code Status: ${challenge.qrCodeStatus}",
                                  style: const TextStyle(fontSize: 14)),
                              ElevatedButton(
                                onPressed: () => _scanQRCode(index),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                child: const Icon(
                                  Icons.qr_code,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        else
                          if (challenge.title == "5-minutes-shower")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Status: ${challenge.showerStatus}",
                                        style: const TextStyle(fontSize: 14)),
                                    Text(
                                      "Timer: ${challenge.elapsedTime ~/ 60}:${(challenge.elapsedTime % 60).toString().padLeft(2, '0')}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () => _toggleShowerTimer(index),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: challenge.isTimerRunning ? Colors.red : Colors.green,
                                  ),
                                  child: Icon(
                                    challenge.isTimerRunning ? Icons.timer_off : Icons.timer,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'ChallengesScreen', // Pass the current screen name
      ),
    );
  }
}


  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Challenges'),
      ),
      body: ListView.builder(
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          final challenge = challenges[index];
          return ListTile(
            title: Text(challenge.title),
            subtitle: challenge.title == "5-minutes-shower"
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Status: ${challenge.showerStatus}"),
                Text(
                  "Elapsed Time: ${challenge.elapsedTime ~/ 60}:${(challenge.elapsedTime % 60).toString().padLeft(2, '0')}",
                ),
              ],
            )
                : challenge.totalSteps == 5000 || challenge.totalSteps == 10000 || challenge.totalSteps == 20000 || challenge.totalSteps == 50000
                ? Text("${challenge.currentSteps} / ${challenge.totalSteps} steps")
                : challenge.totalSteps == 120
                ? Text("${challenge.currentSteps} / ${challenge.totalSteps} minutes")
                : challenge.title == "Car-Free Day"
                ? Text("Status: ${challenge.carFreeStatus}")
                : challenge.title == "Rode a Bike Today"
                ? Text("Status: ${challenge.bikeRideStatus}")
                : challenge.title == "Go to Clean-up Event" ||
                challenge.title == "Go to Eco-friendly Market" ||
                challenge.title == "Go to Sustainable Food Festival" ||
                challenge.title == "Go to Tree Planting Event" ||
                challenge.title == "Go to Bicycle Parade" ||
                challenge.title == "Go to Group Walk Event" ||
                challenge.title == "Play a Sport Event" ||
                challenge.title == "Go to Car-free Day Meet-up" ||
                challenge.title == "Join a Car Pool" ||
                challenge.title == "Support Local Commerce" ||
                challenge.title == "Go to Thrift Store" ||
                challenge.title == "Use Public Transport"
                ? Text("QR Code Status: ${challenge.qrCodeStatus}")
                : Text(challenge.description),
            trailing: challenge.title == "5-minutes-shower"
                ? ElevatedButton(
              onPressed: () => _toggleShowerTimer(index),
              child: Text(challenge.isTimerRunning ? "Stop Timer" : "Start Timer"),
            )
                : challenge.title == "Go to Clean-up Event" ||
                challenge.title == "Go to Eco-friendly Market" ||
                challenge.title == "Go to Sustainable Food Festival" ||
                challenge.title == "Go to Tree Planting Event" ||
                challenge.title == "Go to Bicycle Parade" ||
                challenge.title == "Go to Group Walk Event" ||
                challenge.title == "Play a Sport Event" ||
                challenge.title == "Go to Car-free Day Meet-up" ||
                challenge.title == "Join a Car Pool" ||
                challenge.title == "Support Local Commerce" ||
                challenge.title == "Go to Thrift Store" ||
                challenge.title == "Use Public Transport"
                ? ElevatedButton(
              onPressed: () => _scanQRCode(index),
              child: const Text("Read QR Code"),
            )
                : Text('${challenge.points} Points'),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'ChallengesScreen', // Pass the current screen name
      ),
    );
  }
}*/




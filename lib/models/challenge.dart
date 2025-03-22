// lib/models/challenge.dart

class Challenge {
  final String title;
  final String description;
  final int points;
  final int totalSteps; // Total steps required for this challenge
  int currentSteps; // Current steps completed (mutable)
  String carFreeStatus; // For Car-Free Day challenge
  String bikeRideStatus; // New property for bike-riding status
  bool isTimerRunning; // For tracking if the timer is running
  int elapsedTime; // Elapsed time in seconds
  String showerStatus; // Status of the shower (porcalhÃ£o, quick-shower, long-shower)

  Challenge({
    required this.title,
    required this.description,
    required this.points,
    this.totalSteps = 0, // Default to 0 if not a step-based challenge
    this.currentSteps = 0, // Start with 0 steps completed
    this.carFreeStatus = "car-free by now", // Default status for Car-Free Day
    this.bikeRideStatus = "not done yet", // Default status for bike-riding
    this.isTimerRunning = false, // Timer is not running initially
    this.elapsedTime = 0, // Elapsed time starts at 0
    this.showerStatus = "not started", // Initial shower status
  });
}
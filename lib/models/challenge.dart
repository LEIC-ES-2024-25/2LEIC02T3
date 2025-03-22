// lib/models/challenge.dart

class Challenge {
  final String title;
  final String description;
  final int points;
  final int totalSteps; // Total steps required for this challenge
  int currentSteps; // Current steps completed (mutable)
  String carFreeStatus; // For Car-Free Day challenge
  String bikeRideStatus; // New property for bike-riding status


  Challenge({
    required this.title,
    required this.description,
    required this.points,
    this.totalSteps = 0, // Default to 0 if not a step-based challenge
    this.currentSteps = 0, // Start with 0 steps completed
    this.carFreeStatus = "car-free by now", // Default status for Car-Free Day
    this.bikeRideStatus = "not done yet", // Default status for bike-riding
  });
}
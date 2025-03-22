class Challenge {
  final String title;
  final String description;
  final int points;
  final int totalSteps; // Total steps required for this challenge
  int currentSteps; // Current steps completed (mutable)


  Challenge({
    required this.title,
    required this.description,
    required this.points,
    this.totalSteps = 0, // Default to 0 if not a step-based challenge
    this.currentSteps = 0, // Start with 0 steps completed
  });
}
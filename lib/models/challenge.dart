class Challenge {
  final String id;
  String title;
  String description;
  int points;
  int totalSteps; 
  int currentSteps; 
  String carFreeStatus; 
  String bikeRideStatus; 
  bool isTimerRunning; 
  int elapsedTime; 
  String showerStatus;
  String qrCodeStatus;
  bool isCompleted;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    this.totalSteps = 0, 
    this.currentSteps = 0, 
    this.carFreeStatus = "car-free by now", 
    this.bikeRideStatus = "not done yet", 
    this.isTimerRunning = false, 
    this.elapsedTime = 0, 
    this.showerStatus = "not started",
    this.qrCodeStatus = "not scanned",
    this.isCompleted = false,
  });
}
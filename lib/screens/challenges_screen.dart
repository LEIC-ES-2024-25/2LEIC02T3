import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge.dart';
import '../providers/challenges_provider.dart';
import 'bottom_navigation_bar.dart';
import 'qr_scanner_screen.dart'; // Import the QR scanner screen

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Challenges',
        style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green, // Green app bar
      ),
      backgroundColor: Colors.green.shade100, // Green background for the entire screen
      body: Consumer<ChallengesProvider>(
        builder: (context, challengesProvider, child) {
          final challenges = challengesProvider.challenges;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  color: Colors.white, // White cards
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildChallengeCard(context, challenge, challengesProvider),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'ChallengesScreen',
      ),
    );
  }
  
  Widget _buildChallengeCard(BuildContext context, Challenge challenge, ChallengesProvider provider) {
    switch (challenge.id) {
      case 'steps':
        return _buildStepsChallenge(context, challenge, provider);
      case 'car-free':
        return _buildCarFreeChallenge(challenge);
      case 'bike':
        return _buildBikeChallenge(challenge);
      case 'shower':
        return _buildShowerChallenge(context, challenge, provider);
      case 'screen-time':
        return _buildScreenTimeChallenge(challenge);
      case 'cleanup':
        return _buildCleanupEventChallenge(context, challenge);
      default:
        return const SizedBox();
    }
  }
  
  Widget _buildStepsChallenge(BuildContext context, Challenge challenge, ChallengesProvider provider) {
    final progress = challenge.currentSteps / challenge.totalSteps;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                challenge.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${challenge.points} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(challenge.description),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${challenge.currentSteps} / ${challenge.totalSteps} steps'),
            if (!challenge.isCompleted && progress >= 1.0)
              ElevatedButton(
                onPressed: () => provider.completeChallenge(challenge.id, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Complete', style: TextStyle(color: Colors.white)),
              )
            else if (challenge.isCompleted)
              const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ],
    );
  }
  
  Widget _buildCarFreeChallenge(Challenge challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                challenge.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${challenge.points} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(challenge.description),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Status: ${challenge.carFreeStatus}'),
          ],
        ),
      ],
    );
  }
  
  Widget _buildBikeChallenge(Challenge challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                challenge.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${challenge.points} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(challenge.description),
        const SizedBox(height: 12),
        Text('Status: ${challenge.bikeRideStatus}'),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {
            // Implement bike ride completion logic
          },
          icon: const Icon(Icons.directions_bike),
          label: const Text('I Rode a Bike Today'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
  
  Widget _buildShowerChallenge(BuildContext context, Challenge challenge, ChallengesProvider provider) {
    String displayTime = '';
    final minutes = challenge.elapsedTime ~/ 60;
    final seconds = challenge.elapsedTime % 60;
    displayTime = '$minutes:${seconds.toString().padLeft(2, '0')}';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                challenge.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${challenge.points} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(challenge.description),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.timer, color: Colors.orange),
            const SizedBox(width: 8),
            Text('Time: $displayTime'),
            const Spacer(),
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text('Status: ${challenge.showerStatus}'),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => provider.toggleShowerTimer(context),
          icon: Icon(challenge.isTimerRunning ? Icons.stop : Icons.play_arrow),
          label: Text(challenge.isTimerRunning ? 'Stop Shower' : 'Start Shower'),
          style: ElevatedButton.styleFrom(
            backgroundColor: challenge.isTimerRunning ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
  
  Widget _buildScreenTimeChallenge(Challenge challenge) {
    final hours = challenge.currentSteps ~/ 60;
    final minutes = challenge.currentSteps % 60;
    final displayTime = '$hours:${minutes.toString().padLeft(2, '0')}';
    final progress = challenge.currentSteps / challenge.totalSteps;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                challenge.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${challenge.points} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(challenge.description),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          color: progress >= 1.0 ? Colors.red : Colors.green,
        ),
        const SizedBox(height: 8),
        Text('Screen time today: $displayTime hours'),
      ],
    );
  }
  
  Widget _buildCleanupEventChallenge(BuildContext context, Challenge challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                challenge.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${challenge.points} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(challenge.description),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.qr_code, color: Colors.purple),
            const SizedBox(width: 8),
            Text('Status: ${challenge.qrCodeStatus}'),
          ],
        ),
        const SizedBox(height: 12),
        if (!challenge.isCompleted)
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to the QRScannerScreen
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const QRScannerScreen())
              );
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        if (challenge.isCompleted)
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Challenge completed!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ],
          ),
      ],
    );
  }
}




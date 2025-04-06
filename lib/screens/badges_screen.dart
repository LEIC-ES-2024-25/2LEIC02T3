import 'package:flutter/material.dart';
import '../models/badge.dart';
import '../services/badge_service.dart';
import 'bottom_navigation_bar.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final badges = BadgeService().getAllBadges();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Badges'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earn badges by completing eco-friendly challenges!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180, // Slightly smaller maximum width
                  childAspectRatio: 1, // More height compared to width
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  return BadgeTile(badge: badges[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'BadgesScreen',
      ),
    );
  }
}

class BadgeTile extends StatelessWidget {
  final Badge_ badge;

  const BadgeTile({Key? key, required this.badge}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Reduced padding
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate icon size based on available width
            final iconSize = constraints.maxWidth * 0.25;
            
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconSize * 0.3),
                      decoration: BoxDecoration(
                        color: badge.isUnlocked ? Colors.green.shade100 : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge.icon,
                        size: iconSize,
                        color: badge.isUnlocked ? Colors.green : Colors.grey,
                      ),
                    ),
                    if (!badge.isUnlocked)
                      Container(
                        padding: EdgeInsets.all(iconSize * 0.1),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock,
                          size: iconSize * 0.5,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    badge.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: badge.isUnlocked ? Colors.green : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Text(
                    badge.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${badge.pointsToGain} points',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
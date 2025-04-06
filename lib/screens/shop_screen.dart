import 'package:flutter/material.dart';
import 'bottom_navigation_bar.dart';
import '../widgets/points_tracker.dart';
import '../providers/points_provider.dart';
import 'package:provider/provider.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: PointsTracker(),
          ),
        ],
      ),
      body: Consumer<PointsProvider>(
        builder: (context, pointsProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Eco Points Balance',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Points',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${pointsProvider.points}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Shop Items Coming Soon',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Use your points to purchase sustainable products and rewards.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        }
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        currentScreen: 'ShopScreen',
      ),
    );
  }
}
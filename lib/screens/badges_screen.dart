import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/badge.dart';
import '../providers/badges_provider.dart';
import 'bottom_navigation_bar.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suas Conquistas',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.green.shade50,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.eco, color: Colors.green, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Conquiste Distintivos!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Complete desafios ecológicos para ganhar distintivos especiais',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<BadgesProvider>(
              builder: (context, badgesProvider, child) {
                final badges = badgesProvider.badges;
                if (badges.isEmpty) {
                  return const Expanded(
                    child: Center(
                      child: Text(
                        'Nenhum distintivo disponível ainda',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 180,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) {
                      return BadgeTile(badge: badges[index]);
                    },
                  ),
                );
              },
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
        borderRadius: BorderRadius.circular(16),
      ),
      color: badge.isUnlocked ? Colors.white : Colors.grey.shade100,
      child: InkWell(
        onTap: () {
          _showBadgeDetails(context, badge);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: badge.isUnlocked
                          ? LinearGradient(
                        colors: [Colors.green.shade300, Colors.green.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                          : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: badge.isUnlocked
                              ? Colors.green.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      badge.icon,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  if (!badge.isUnlocked)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.lock,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                badge.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: badge.isUnlocked ? Colors.green.shade800 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badge.isUnlocked ? Colors.orange.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${badge.pointsToGain} pontos',
                  style: TextStyle(
                    fontSize: 12,
                    color: badge.isUnlocked ? Colors.orange.shade800 : Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBadgeDetails(BuildContext context, Badge_ badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          badge.name,
          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: badge.isUnlocked ? Colors.green.shade100 : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                badge.icon,
                size: 50,
                color: badge.isUnlocked ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Valor: ${badge.pointsToGain} pontos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.isUnlocked ? 'Distintivo desbloqueado!' : 'Complete desafios para desbloquear',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: badge.isUnlocked ? Colors.green : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
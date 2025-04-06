import 'package:flutter/material.dart';

class Badge_ {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int pointsToGain;
  bool isUnlocked;

  Badge_({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    required this.pointsToGain,
  });
}
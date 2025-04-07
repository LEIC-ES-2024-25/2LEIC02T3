import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsProvider with ChangeNotifier {
  static const String _pointsKey = 'user_points';
  int _points = 0;
  
  PointsProvider() {
    _loadPoints();
  }
  
  int get points => _points;
  
  Future<void> _loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _points = prefs.getInt(_pointsKey) ?? 0;
    notifyListeners();
  }
  
  Future<void> _savePoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pointsKey, _points);
  }
  
  Future<void> addPoints(int amount) async {
    if (amount <= 0) return;
    
    _points += amount;
    await _savePoints();
    notifyListeners();
  }
  
  Future<bool> usePoints(int amount) async {
    if (amount <= 0 || _points < amount) return false;
    
    _points -= amount;
    await _savePoints();
    notifyListeners();
    return true;
  }
  
  Future<void> resetPoints() async {
    _points = 0;
    await _savePoints();
    notifyListeners();
  }
  
  // Method for development/testing only
  Future<void> setPoints(int value) async {
    if (value < 0) return;
    
    _points = value;
    await _savePoints();
    notifyListeners();
  }
}
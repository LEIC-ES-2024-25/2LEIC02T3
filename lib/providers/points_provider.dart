import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PointsProvider with ChangeNotifier {
  int _points = 0;
  
  PointsProvider() {
    _loadPoints();
  }
  
  int get points => _points;
  
  Future<void> _loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _points = prefs.getInt('user_points') ?? 0;
    notifyListeners();
  }
  
  Future<void> addPoints(int amount) async {
    _points += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_points', _points);
    notifyListeners();
  }
  
  Future<void> usePoints(int amount) async {
    if (_points >= amount) {
      _points -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_points', _points);
      notifyListeners();
    }
  }
}
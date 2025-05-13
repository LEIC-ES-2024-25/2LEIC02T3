import 'package:flutter/material.dart';
import '../models/material.dart';

class MaterialsProvider with ChangeNotifier {
  final List<StudyMaterial> _materials = [];

  List<StudyMaterial> get materials => [..._materials];

  void addMaterial(StudyMaterial material) {
    _materials.add(material);
    notifyListeners();
  }

  List<StudyMaterial> searchMaterials(String query) {
    return _materials
        .where((material) =>
            material.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<StudyMaterial> filterMaterials(String category) {
    return _materials.where((material) => material.category == category).toList();
  }
}
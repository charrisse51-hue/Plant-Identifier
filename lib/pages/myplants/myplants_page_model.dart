import 'package:flutter/material.dart';
import '../../api/saved_plants_api.dart';

class MyplantsPageModel extends ChangeNotifier {
  List<dynamic> plants = [];
  bool isLoading = true;
  String? errorMessage;

  MyplantsPageModel() {
    loadPlants();
  }

  Future<void> loadPlants() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      plants = await SavedPlantsApi.fetchSavedPlants();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPlants() => loadPlants();

  Future<void> deletePlant(dynamic id) async {
    final idx = plants.indexWhere((p) => p['id'] == id);
    if (idx != -1) {
      final removed = plants.removeAt(idx);
      notifyListeners();
      try {
        final plantId = id is int ? id : int.parse(id.toString());
        await SavedPlantsApi.deleteSavedPlant(plantId);
      } catch (e) {
        plants.insert(idx, removed);
        notifyListeners();
        rethrow;
      }
    }
  }
}

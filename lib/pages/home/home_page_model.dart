import 'dart:async';
import 'package:flutter/material.dart';
import '../../api/random_plant_api.dart';

class HomePageModel extends ChangeNotifier {
  late Future<List<Plant>> plantsFuture;
  String headerText = 'Plant Identifier';
  Timer? _headerTimer;

  HomePageModel() {
    _init();
  }

  void _init() {
    plantsFuture = RandomPlantApi.fetchRandomPlants();
    _startHeaderTimer();
  }

  void _startHeaderTimer() {
    _headerTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      headerText =
      headerText == 'Plant Identifier' ? 'Scan and Learn' : 'Plant Identifier';
      notifyListeners();
    });
  }

  Future<void> refreshPlants() async {
    plantsFuture = RandomPlantApi.fetchRandomPlants();
    notifyListeners();
  }

  void disposeModel() {
    _headerTimer?.cancel();
  }
}

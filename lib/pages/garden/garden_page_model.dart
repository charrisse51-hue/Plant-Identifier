import 'package:flutter/material.dart';

class GardenPageModel extends ChangeNotifier {
  final TabController? controller;

  GardenPageModel({this.controller});

  void onTabChanged() {
    notifyListeners();
  }
}

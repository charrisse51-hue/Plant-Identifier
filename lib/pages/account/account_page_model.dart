import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/history_plants_api.dart';
import '../../api/saved_plants_api.dart';

class AccountPageModel extends ChangeNotifier {
  String firstName = "";
  String lastName = "";
  String emailText = "";
  String joinedDate = "";
  String? profileImagePath;

  int scannedCount = 0;
  int ownedCount = 0;
  int savedCount = 0;
  bool isLoadingStats = false;

  final ImagePicker _picker = ImagePicker();

  String get initials {
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
      final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
      return '$f$l';
    }
    return 'P';
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    firstName = prefs.getString('first_name') ?? "";
    lastName = prefs.getString('last_name') ?? "";
    emailText = prefs.getString('email') ?? "";
    joinedDate = prefs.getString('joined_date') ?? "";
    profileImagePath = prefs.getString('profile_image_path');

    notifyListeners();
    await loadStats();
  }

  Future<void> loadStats() async {
    isLoadingStats = true;
    notifyListeners();

    try {
      final history = await HistoryPlantsApi.fetchHistory();
      scannedCount = history.length;
    } catch (e) {
      debugPrint('[AccountPageModel] Failed to fetch scan history count: $e');
    }

    try {
      final saved = await SavedPlantsApi.fetchSavedPlants();
      ownedCount = saved.length; // Plants in "My Plants"
      savedCount = saved.length; // Plants saved
    } catch (e) {
      debugPrint('[AccountPageModel] Failed to fetch saved plants count: $e');
    }

    isLoadingStats = false;
    notifyListeners();
  }

  Future<void> pickProfilePhoto(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', picked.path);
        profileImagePath = picked.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[AccountPageModel] Failed to pick profile photo: $e');
    }
  }

  Future<void> removeProfilePhoto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_image_path');
    profileImagePath = null;
    notifyListeners();
  }

  Color getRandomDarkColor() {
    final Random random = Random((firstName.hashCode ^ lastName.hashCode).abs());
    int r = 30 + random.nextInt(50);
    int g = 70 + random.nextInt(50);
    int b = 40 + random.nextInt(50);
    return Color.fromARGB(255, r, g, b);
  }

  Future<void> logout(BuildContext context, Future<void> Function() clearPrefs, VoidCallback navigateToWelcome) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2621),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2E3D34)),
        ),
        title: const Text(
          'Confirm Log Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await clearPrefs();
      navigateToWelcome();
    }
  }
}

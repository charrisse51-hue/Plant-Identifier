import 'package:flutter/material.dart';
import 'package:flutter_projects/pages/account/account_page.dart';
import 'package:flutter_projects/pages/garden/garden_page.dart';
import '../chat bot/chat_bot_page.dart';
import '../home/home_page.dart';
import '../camera/camera_page.dart';

class NavbarPageModel {
  late BuildContext _context;
  late void Function(VoidCallback fn) _setState;

  int selectedIndex = 0;

  void init(BuildContext context, void Function(VoidCallback fn) setState) {
    _context = context;
    _setState = setState;
  }

  final List<Widget> pages = const [
    HomePage(),
    GardenPage(),
    ChatBotPage(),
    AccountPage(),
  ];

  void onTabSelected(int index) {
    _setState(() {
      selectedIndex = index;
    });
  }

  void onCameraPressed() {
    Navigator.push(
      _context,
      MaterialPageRoute(builder: (context) => const CameraPage()),
    );
  }
}

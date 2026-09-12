import 'package:flutter/material.dart';
import 'package:flutter_projects/color/app_colors.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'navbar_page_model.dart';

class NavbarPage extends StatefulWidget {
  const NavbarPage({super.key});

  @override
  State<NavbarPage> createState() => _NavbarPageState();
}

class _NavbarPageState extends State<NavbarPage> {
  final NavbarPageModel _model = NavbarPageModel();

  @override
  void initState() {
    super.initState();
    _model.init(context, setState);
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      extendBody: false,
      resizeToAvoidBottomInset: true,
      body: _model.pages[_model.selectedIndex],
      bottomNavigationBar: isKeyboardOpen
          ? null
          : Container(
              color: AppColors.surfaceA10.withAlpha(179),
              child: SafeArea(
                top: false,
                bottom: true,
                child: StylishBottomBar(
                  option: DotBarOptions(
                    iconSize: 22,
                    dotStyle: DotStyle.tile,
                  ),
                  items: [
                    BottomBarItem(
                      icon: const Icon(LucideIcons.house400),
                      title: const Text('Home', style: TextStyle(fontSize: 12)),
                      selectedColor: AppColors.primaryDark10,
                      unSelectedColor: AppColors.surfaceA50,
                    ),
                    BottomBarItem(
                      icon: const Icon(LucideIcons.sprout400),
                      title: const Text('Garden', style: TextStyle(fontSize: 12)),
                      selectedColor: AppColors.primaryDark10,
                      unSelectedColor: AppColors.surfaceA50,
                    ),
                    BottomBarItem(
                      icon: const Icon(LucideIcons.botMessageSquare400),
                      title: const Text('Chat-bot', style: TextStyle(fontSize: 12)),
                      selectedColor: AppColors.primaryDark10,
                      unSelectedColor: AppColors.surfaceA50,
                    ),
                    BottomBarItem(
                      icon: const Icon(LucideIcons.userRound400),
                      title: const Text('Account', style: TextStyle(fontSize: 12)),
                      selectedColor: AppColors.primaryDark10,
                      unSelectedColor: AppColors.surfaceA50,
                    ),
                  ],
                  fabLocation: StylishBarFabLocation.end,
                  notchStyle: NotchStyle.square,
                  hasNotch: true,
                  backgroundColor: Colors.transparent,
                  currentIndex: _model.selectedIndex,
                  onTap: _model.onTabSelected,
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: isKeyboardOpen
          ? null
          : FloatingActionButton(
              backgroundColor: AppColors.primaryDark10,
              onPressed: _model.onCameraPressed,
              child: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.surfaceA80,
                size: 28,
              ),
            ),
    );
  }
}

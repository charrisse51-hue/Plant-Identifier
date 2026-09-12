import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_config.dart';
import '../color/app_colors.dart';
import '../pages/welcome/welcome_page.dart';
import '../pages/navbar/navbar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await initApiConfig();

  // Check if user data exists in SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final rememberMe = prefs.getBool('remember_me') ?? true;
  final hasUserData = rememberMe &&
      prefs.containsKey('first_name') &&
      prefs.containsKey('last_name') &&
      prefs.containsKey('email') &&
      prefs.containsKey('joined_date');

  runApp(MyApp(startOnNavbar: hasUserData));
}

class MyApp extends StatelessWidget {
  final bool startOnNavbar;

  const MyApp({super.key, required this.startOnNavbar});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Identifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.surfaceA0,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryA0,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark10,
            foregroundColor: AppColors.surfaceA80,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: startOnNavbar ? const NavbarPage() : const WelcomePage(),
    );
  }
}

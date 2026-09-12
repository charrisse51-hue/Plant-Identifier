import 'package:flutter/material.dart';
import '../sign up/signup_page.dart';
import '../log in/login_page.dart';

class WelcomePageModel {
  void goToSignup(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupPage()),
    );
  }

  void goToSignin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}

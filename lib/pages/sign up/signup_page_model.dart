import 'package:flutter/material.dart';
import 'package:flutter_projects/api/user_auth_api.dart';
import '../log in/login_page.dart';

class SignupPageModel {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool isLoading = false;
  bool _disposed = false;

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  void dispose() {
    _disposed = true;
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  void togglePasswordVisibility(void Function(void Function()) setState) {
    setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void toggleConfirmPasswordVisibility(
    void Function(void Function()) setState,
  ) {
    setState(() {
      confirmPasswordVisible = !confirmPasswordVisible;
    });
  }

  Future<Map<String, dynamic>> registerUser(
    void Function(void Function()) setState,
  ) async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    // Passwords are significant character-for-character; do not alter them.
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        firstNameError = firstName.isEmpty
            ? 'Please enter your first name.'
            : null;
        lastNameError = lastName.isEmpty
            ? 'Please enter your last name.'
            : null;
        emailError = email.isEmpty ? 'Please enter your email.' : null;
        passwordError = password.isEmpty ? 'Please enter a password.' : null;
        confirmPasswordError = confirmPassword.isEmpty
            ? 'Please confirm your password.'
            : null;
      });
      return {
        'success': false,
        'message': 'Please fill in all required fields.',
      };
    }

    if (password != confirmPassword) {
      setState(() {
        passwordError = 'Passwords do not match.';
        confirmPasswordError = 'Passwords do not match.';
      });
      return {'success': false, 'message': 'Passwords do not match.'};
    }

    setState(() {
      isLoading = true;
      firstNameError = null;
      lastNameError = null;
      emailError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    final result = await UserAuthApi.registerUser(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
    if (_disposed) {
      return {'success': false, 'message': 'Request cancelled.'};
    }

    if (!_disposed) {
      setState(() {
        isLoading = false;
      });
    }

    return result;
  }

  void applyFieldErrors(Map<String, dynamic> errors) {
    firstNameError = _extractError(errors, 'first_name');
    lastNameError = _extractError(errors, 'last_name');
    emailError = _extractError(errors, 'email');
    passwordError = _extractError(errors, 'password');
    confirmPasswordError = _extractError(errors, 'confirm_password');
  }

  String? getGeneralError(Map<String, dynamic> errors) {
    return _extractError(errors, 'error') ??
        _extractError(errors, 'message') ??
        _extractError(errors, '__all__') ??
        _extractError(errors, 'non_field_errors');
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  String? _extractError(Map<String, dynamic> errors, String key) {
    final value = errors[key];
    if (value is List && value.isNotEmpty) {
      return value.first?.toString();
    }
    if (value is String) {
      return value;
    }
    return null;
  }
}

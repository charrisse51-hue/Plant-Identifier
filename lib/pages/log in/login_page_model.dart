import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/user_auth_api.dart';

class LoginPageModel {
  late void Function(VoidCallback fn) _setState;
  bool _disposed = false;

  bool passwordVisible = false;
  bool isLoading = false;
  bool rememberMe = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? emailError;
  String? passwordError;

  void init(void Function(VoidCallback fn) setState) {
    _setState = setState;
    loadRememberedAccount();
  }

  Future<void> loadRememberedAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRemember = prefs.getBool('remember_me');
      final savedEmail = prefs.getString('remembered_email');

      if (_disposed) return;

      if (savedRemember != null) {
        rememberMe = savedRemember;
      }

      if (rememberMe && savedEmail != null && savedEmail.isNotEmpty) {
        emailController.text = savedEmail;
      }

      _setState(() {});
    } catch (e) {
      debugPrint('Error loading remembered account: $e');
    }
  }

  void dispose() {
    _disposed = true;
    emailController.dispose();
    passwordController.dispose();
  }

  void togglePasswordVisibility() {
    _setState(() {
      passwordVisible = !passwordVisible;
    });
  }

  void toggleRememberMe(bool value) {
    _setState(() {
      rememberMe = value;
    });
  }

  Future<void> _saveUserData(Map<String, dynamic> user, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', user['userId'] ?? 0);
    await prefs.setString('first_name', user['first_name'] ?? '');
    await prefs.setString('last_name', user['last_name'] ?? '');
    await prefs.setString('email', user['email'] ?? email);
    await prefs.setString('joined_date', user['joined_date'] ?? '');

    await prefs.setBool('remember_me', rememberMe);
    if (rememberMe) {
      await prefs.setString('remembered_email', email);
    } else {
      await prefs.remove('remembered_email');
    }
  }

  Future<Map<String, dynamic>> loginUser() async {
    final email = emailController.text.trim();
    // Passwords are significant character-for-character; do not alter them.
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _setState(() {
        emailError = email.isEmpty ? 'Please enter your email.' : null;
        passwordError = password.isEmpty ? 'Please enter your password.' : null;
      });
      return {
        'success': false,
        'message': 'Please fill in both email and password.',
      };
    }

    _setState(() {
      isLoading = true;
      emailError = null;
      passwordError = null;
    });

    final result = await UserAuthApi.loginUser(
      email: email,
      password: password,
    );
    if (_disposed) {
      return {'success': false, 'message': 'Request cancelled.'};
    }

    if (result['success'] == true) {
      final user = result['user'];
      if (user != null && user is Map<String, dynamic>) {
        await _saveUserData(user, email);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('remember_me', rememberMe);
        if (rememberMe) {
          await prefs.setString('remembered_email', email);
        } else {
          await prefs.remove('remembered_email');
        }
      }
    }

    if (!_disposed) {
      _setState(() {
        isLoading = false;
      });
    }

    return result;
  }

  void applyFieldErrors(Map<String, dynamic> errors) {
    _setState(() {
      emailError = _extractError(errors, 'email');
      passwordError =
          _extractError(errors, 'password') ??
          _extractError(errors, '__all__') ??
          _extractError(errors, 'error');
    });
  }

  String? getGeneralError(Map<String, dynamic> errors) {
    return _extractError(errors, 'message') ??
        _extractError(errors, 'non_field_errors') ??
        _extractError(errors, 'error') ??
        _extractError(errors, '__all__');
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

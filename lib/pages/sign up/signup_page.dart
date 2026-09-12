import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_projects/color/app_colors.dart';
import '../log in/login_page.dart';
import 'signup_page_model.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final SignupPageModel model = SignupPageModel();

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

  Future<void> _handleSignupTap() async {
    if (!mounted) return;

    final result = await model.registerUser(setState);
    if (!mounted) return;

    if (result['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'User registered successfully')),
        );
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
      return;
    }

    final errors = result['errors'];
    if (errors is Map<String, dynamic>) {
      setState(() {
        model.applyFieldErrors(errors);
      });

      final generalMessage = model.getGeneralError(errors);
      final fieldMessage = errors.values
          .map((value) {
            if (value is List && value.isNotEmpty) return value.first?.toString();
            if (value is String) return value;
            return null;
          })
          .whereType<String>()
          .firstWhere((_) => true, orElse: () => 'Registration failed. Please check your input.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(generalMessage ?? fieldMessage)),
        );
      }
      return;
    }

    final message = result['message']?.toString() ??
        result['error']?.toString() ??
        'Registration failed. Please check your backend and network connection.';
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 80, bottom: 50, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Sign Up",
                    style: TextStyle(color: AppColors.primaryA0, fontSize: 40),
                  ),
                  const SizedBox(height: 50),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: model.firstNameController,
                        decoration: InputDecoration(
                          hintText: 'First Name',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(LucideIcons.userRound300, size: 24),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          errorText: model.firstNameError,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: model.lastNameController,
                        decoration: InputDecoration(
                          hintText: 'Last Name',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(LucideIcons.userRound300, size: 24),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          errorText: model.lastNameError,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: model.emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(LucideIcons.mail300, size: 24),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          errorText: model.emailError,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        obscureText: !model.passwordVisible,
                        controller: model.passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(LucideIcons.lock300, size: 24),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () => model.togglePasswordVisibility(setState),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                model.passwordVisible ? LucideIcons.eyeOff300 : LucideIcons.eye300,
                                size: 24,
                              ),
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          errorText: model.passwordError,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        obscureText: !model.confirmPasswordVisible,
                        controller: model.confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(LucideIcons.lockKeyhole300, size: 24),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () => model.toggleConfirmPasswordVisibility(setState),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                model.confirmPasswordVisible ? LucideIcons.eyeOff300 : LucideIcons.eye300,
                                size: 24,
                              ),
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          errorText: model.confirmPasswordError,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: model.isLoading ? null : _handleSignupTap,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                        child: model.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Sign Up', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(fontSize: 12, color: AppColors.surfaceA50),
                      ),
                      GestureDetector(
                        onTap: () => model.goToLogin(context),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryA20,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryA20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

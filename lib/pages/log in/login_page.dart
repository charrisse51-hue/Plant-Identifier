import 'package:flutter/material.dart';
import 'package:flutter_projects/color/app_colors.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../navbar/navbar_page.dart';
import 'login_page_model.dart';
import '../sign up/signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginPageModel _model = LoginPageModel();

  @override
  void initState() {
    super.initState();
    _model.init(setState);
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _handleLoginTap() async {
    if (!mounted) return;

    final result = await _model.loginUser();
    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const NavbarPage()),
        (route) => false,
      );
      return;
    }

    final errors = result['errors'];
    if (errors is Map<String, dynamic>) {
      _model.applyFieldErrors(errors);
      setState(() {});

      final generalMessage = _model.getGeneralError(errors);
      final fieldMessage = generalMessage ??
          errors.values
              .map((value) {
                if (value is List && value.isNotEmpty) return value.first?.toString();
                if (value is String) return value;
                return null;
              })
              .whereType<String>()
              .firstWhere((_) => true, orElse: () => 'Login failed. Please check your credentials.');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(fieldMessage)),
        );
      }
      return;
    }

    final message = result['message']?.toString() ??
        result['error']?.toString() ??
        'Login failed. Please check your credentials and network connection.';
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Log In",
                    style: TextStyle(color: AppColors.primaryA0, fontSize: 40),
                  ),
                  const SizedBox(height: 50),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _model.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(LucideIcons.mail, size: 24),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          errorText: _model.emailError,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _model.passwordController,
                        obscureText: !_model.passwordVisible,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Icon(LucideIcons.lockKeyhole, size: 24),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: _model.togglePasswordVisibility,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                _model.passwordVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                                size: 24,
                              ),
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          errorText: _model.passwordError,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _model.rememberMe,
                                onChanged: (val) {
                                  _model.toggleRememberMe(val ?? false);
                                },
                                activeColor: AppColors.primaryA0,
                                checkColor: Colors.black,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                side: const BorderSide(
                                  color: AppColors.surfaceA50,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _model.toggleRememberMe(!_model.rememberMe),
                              child: const Text(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.surfaceA80,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _model.isLoading ? null : _handleLoginTap,
                        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
                        child: _model.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'Log In',
                                style: TextStyle(fontSize: 20),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't Have an account?",
                        style: TextStyle(fontSize: 12, color: AppColors.surfaceA50),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupPage()),
                          );
                        },
                        child: Text(
                          ' Sign Up',
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

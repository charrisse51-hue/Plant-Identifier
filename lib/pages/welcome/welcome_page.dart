import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../color/app_colors.dart';
import 'welcome_page_model.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = WelcomePageModel();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/images/logo.svg',
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Plant Identifier',
                      style: TextStyle(
                        fontSize: 30,
                        letterSpacing: 2,
                        color: AppColors.primaryDark10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => model.goToSignup(context),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(0, 50),
                          ),
                          child: const Text(
                            'Get Started',
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
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.surfaceA50,
                          ),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () => model.goToSignin(context),
                          child: Text(
                            'Sign In',
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

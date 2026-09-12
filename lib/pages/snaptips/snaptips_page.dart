import 'package:flutter/material.dart';
import 'package:flutter_projects/pages/snaptips/snaptips_page_model.dart';
import '../../color/app_colors.dart';

class SnapTipsPage extends StatelessWidget {
  const SnapTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = SnapTipsPageModel();

    return Scaffold(
      backgroundColor: AppColors.surfaceA0,
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Snap Tips",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const Spacer(),
              Image.asset(
                'assets/images/perfect.png',
                width: 190,
                height: 190,
              ),
              const SizedBox(height: 50),
              Row(
                spacing: 3,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  model.tipItem('assets/images/tooclose.png', 'Too close'),
                  model.tipItem('assets/images/toofar.png', 'Too far'),
                  model.tipItem('assets/images/multispecies.png', 'Multi-species'),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryA0,
                  ),
                  onPressed: () => model.onGotItPressed(context),
                  child: const Text(
                    "Got it",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

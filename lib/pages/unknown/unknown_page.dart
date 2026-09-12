import 'package:flutter/material.dart';
import '../../color/app_colors.dart';
import 'unknown_page_model.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = UnknownPageModel();

    return Scaffold(
      backgroundColor: AppColors.surfaceA0,
      body: SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Sorry, couldn't identify",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Try these Snap Tips for taking good pictures for better identification.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.surfaceA50,
                  fontSize: 18,
                ),
              ),
              Spacer(),
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

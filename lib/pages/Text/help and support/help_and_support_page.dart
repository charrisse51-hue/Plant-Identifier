import 'package:flutter/material.dart';

import '../../../color/app_colors.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.surfaceA0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Help & Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              color: AppColors.surfaceA30,
              height: 1.5,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Help & Support for Plant Identifier',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Plant Identifier is here to help you explore and learn about the plants around you. '
                  'If you experience issues, have questions about features, or want to share feedback, our support team is ready to assist.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'How to Reach Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '1. Email us: support@plantidentifier.com\n'
                  '2. Visit our website: www.plantidentifier.com\n'
                  '3. Message us through the in-app feedback form\n'
                  '4. Follow and contact us on our official social media pages.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'FAQs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Q: How do I identify a plant?\n'
                  'A: Tap the camera icon, take or upload a photo of the plant, and the app will identify it.\n\n'
                  'Q: Does the app work offline?\n'
                  'A: The app requires an internet connection to access the plant database and provide accurate results.\n\n'
                  'Q: Can I save identified plants?\n'
                  'A: Yes, you can save them to your personal collection for easy access later.\n\n'
                  'Q: Is the app free?\n'
                  'A: The app is completely free, providing all features and unlimited access to features.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

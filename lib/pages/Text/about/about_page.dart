import 'package:flutter/material.dart';
import 'package:flutter_projects/color/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
            'About',
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
              'Plant Identifier: Discover Nature Around You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Plant Identifier is a mobile application designed to help you recognize and learn about different plants with ease. By simply taking or uploading a photo, the app uses powerful image recognition technology to identify the plant and provide useful details about it.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'What Makes It Useful',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Whether you are a student, researcher, gardener, or just curious about the plants you encounter, Plant Identifier provides quick and reliable information. The app not only identifies the plant species but also offers insights about its uses, care tips, and significance.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'We aim to bridge technology and nature by making plant knowledge accessible to everyone. With Plant Identifier, exploring biodiversity becomes engaging, educational, and practical for everyday life.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 18),
            Text(
              'Start Exploring',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Take a photo, identify the plant, and expand your knowledge of the natural world. Plant Identifier makes learning about nature as simple as a tap on your screen.',
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
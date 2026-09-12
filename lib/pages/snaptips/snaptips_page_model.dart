import 'package:flutter/material.dart';

class SnapTipsPageModel {
  Widget tipItem(String imagePath, String label) {
    return SizedBox(
      width: 90,
      child: Column(
        spacing: 8,
        children: [
          Image.asset(
            imagePath,
            width: 90,
            height: 90,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void onGotItPressed(BuildContext context) {
    Navigator.pop(context);
  }
}

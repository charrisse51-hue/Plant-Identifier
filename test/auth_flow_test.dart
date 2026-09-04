import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_projects/pages/welcome/welcome_page.dart';

void main() {
  testWidgets('welcome screen shows sign-in and get started actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePage()));

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}

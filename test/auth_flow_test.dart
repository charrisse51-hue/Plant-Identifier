import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_projects/pages/welcome/welcome_page.dart';
import 'package:flutter_projects/pages/log in/login_page.dart';

void main() {
  testWidgets('welcome screen shows sign-in and get started actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomePage()));

    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('login screen displays Remember me checkbox and pre-fills remembered account', (tester) async {
    SharedPreferences.setMockInitialValues({
      'remember_me': true,
      'remembered_email': 'saved_user@example.com',
    });

    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.pumpAndSettle();

    expect(find.text('Remember me'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);

    final checkboxFinder = find.byType(Checkbox);
    final checkboxWidget = tester.widget<Checkbox>(checkboxFinder);
    expect(checkboxWidget.value, isTrue);

    expect(find.text('saved_user@example.com'), findsOneWidget);

    // Tap checkbox to toggle
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    final updatedCheckbox = tester.widget<Checkbox>(checkboxFinder);
    expect(updatedCheckbox.value, isFalse);
  });
}

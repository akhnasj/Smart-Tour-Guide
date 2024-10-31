import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stg/login.dart'; // Import LoginPage
import 'package:stg/register.dart'; // Import RegisterPage

void main() {
  group('LoginPage Tests', () {
    testWidgets('LoginPage displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Check if Welcome Text appears
      expect(find.text('Welcome Back!'), findsOneWidget);

      // Check if Email TextField is present
      expect(find.byType(TextField), findsNWidgets(2)); // Email and Password fields

      // Check if Login button is present
      expect(find.text('Login'), findsOneWidget);

      // Tap on Register link and verify
      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      // This should ideally navigate to the RegisterPage
      // In a real app, you could navigate using Navigator for full flow testing
    });
  });

  group('RegisterPage Tests', () {
    testWidgets('RegisterPage displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterPage()));

      // Check if Create Account Text appears
      expect(find.text('Create Account'), findsOneWidget);

      // Check if Full Name, Email, Password fields are present
      expect(find.byType(TextField), findsNWidgets(4)); // Full Name, Email, Password, Confirm Password

      // Check if Register button is present
      expect(find.text('Register'), findsOneWidget);

      // Simulate entering text
      await tester.enterText(find.byType(TextField).at(0), 'John Doe'); // Full Name
      await tester.enterText(find.byType(TextField).at(1), 'johndoe@example.com'); // Email
      await tester.enterText(find.byType(TextField).at(2), 'password123'); // Password
      await tester.enterText(find.byType(TextField).at(3), 'password123'); // Confirm Password

      // Tap on Register button
      await tester.tap(find.text('Register'));
      await tester.pump();

      // In a real app, you could check for registration result or redirection here
    });
  });
}

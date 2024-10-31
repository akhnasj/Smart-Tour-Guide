import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stg/main.dart';
import 'package:stg/login.dart';
import 'package:stg/register.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('Login page has a title and a login button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Verify that the login page has a title and a login button
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Username and Password fields
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('Register page has a title and a register button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterPage()));

      // Verify that the register page has a title and a register button
      expect(find.text('Register'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Username and Password fields
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('Home page has a welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HomePage()));

      // Verify that the home page has a welcome message
      expect(find.text('Welcome to the Smart Tour Guide App!'), findsOneWidget);
    });

    testWidgets('Login button triggers validation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: LoginPage()));

      // Tap the login button without entering credentials
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify that validation messages are shown
      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Register button triggers validation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: RegisterPage()));

      // Tap the register button without entering credentials
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify that validation messages are shown
      expect(find.text('Please enter your username'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Navigation from login to register page', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(),
          '/register': (context) => RegisterPage(),
        },
      ));

      // Tap the register link
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Verify that we navigated to the register page
      expect(find.text('Register'), findsOneWidget);
    });
  });
}

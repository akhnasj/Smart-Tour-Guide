import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';
import 'register.dart';
import 'admin_page.dart'; // Adjust the path as necessary



void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter is ready before initializing Firebase
  await Firebase.initializeApp(); // Initializes Firebase
  runApp(MyTravelApp());
}

class MyTravelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      theme: ThemeData(
        primaryColor: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.orange,
        ),
      ),
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/admin': (context) => AdminPage(), // Add this route
      },
    );
  }
}

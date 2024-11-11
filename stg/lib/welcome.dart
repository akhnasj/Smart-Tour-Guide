// welcome.dart
import 'package:flutter/material.dart';

class WelcomeAdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, Admin!!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'You can manage the locations and reviews here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

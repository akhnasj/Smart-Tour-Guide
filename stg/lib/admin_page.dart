import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 100,
                color: Colors.teal,
              ),
              SizedBox(height: 20),
              Text(
                'Welcome, Admin!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Manage the app\'s content and settings here.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.teal[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Example buttons for admin functionality
              ElevatedButton(
                onPressed: () {
                  // Navigate to another admin function, e.g., user management
                  Navigator.pushNamed(context, 'user_management_page');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: Text(
                  'User Management',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  // Navigate to another admin function, e.g., content management
                  Navigator.pushNamed(context, 'content_management_page');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: Text(
                  'Content Management',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  // Log out functionality or return to login page
                  Navigator.pop(context); // Go back to the previous page (login)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Different color for logout
                ),
                child: Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

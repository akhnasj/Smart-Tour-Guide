import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // GlobalKey for form validation

Future<void> _loginUser() async {
  // Validate the form fields
  if (!_formKey.currentState!.validate()) {
    return; // If the form is not valid, exit the method
  }

  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  try {
    // Special admin login
    if (email == "akhna@gmail.com" && password == "akhnasj") {
      // Navigate to Admin Page
      Navigator.pushNamed(context, '/admin');
      _clearFields(); // Clear fields after navigation
    } else {
      // Regular tourist login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.pushNamed(context, 'home_page');
      _clearFields(); // Clear fields after navigation
    }
  } on FirebaseAuthException catch (e) {
    // Handling specific FirebaseAuth errors
    if (e.code == 'user-not-found') {
      _showError("No user found with this email.");
    } else if (e.code == 'wrong-password') {
      _showError("Incorrect password. Please try again.");
    } else {
      _showError("Login failed: ${e.message}");
    }
  }
}

void _clearFields() {
  _emailController.clear();
  _passwordController.clear();
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey, // Assign the GlobalKey to the Form
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.explore, size: 80, color: Colors.teal),
                  SizedBox(height: 20),
                  Text(
                    'Welcome Back!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Login to continue exploring',
                    style: TextStyle(fontSize: 16, color: Colors.teal[800]),
                  ),
                  SizedBox(height: 30),

                  // Email TextField
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email field is required.'; // Error message
                      }
                      return null; // Valid input
                    },
                  ),
                  SizedBox(height: 15),

                  // Password TextField
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password field is required.'; // Error message
                      }
                      return null; // Valid input
                    },
                  ),
                  SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Register Navigation Button
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: Text(
                      'Don\'t have an account? Create one now!',
                      style: TextStyle(fontSize: 16, color: Colors.teal[700], fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

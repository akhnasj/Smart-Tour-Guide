import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Import the dart:math library to use Random class

// Function to generate a random 5-digit number
String generateTouristId() {
  final random = Random();
  int id = random.nextInt(90000) + 10000; // Generates a number between 10000 and 99999
  return id.toString();
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _gender; // Variable to hold gender selection
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _passwordError; // Variable to hold password error message

Future<void> _registerUser() async {
  if (_formKey.currentState!.validate()) {
    // If form validation passes, check for password match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = "Passwords do not match"; // Set the error message
      });
      return; // Exit the function if passwords do not match
    }

    setState(() {
      _passwordError = null; // Reset error message if passwords match
    });

    try {
  // Firebase authentication and user creation logic
  UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: _emailController.text,
    password: _passwordController.text,
  );

  // Generate unique tourist ID
  String tId = generateTouristId(); // Use the function here

  // Saving user data to Firestore
  await FirebaseFirestore.instance.collection('tourist').doc(userCredential.user!.uid).set({
    't_id': tId,
    'firstName': _firstNameController.text,
    'lastName': _lastNameController.text,
    'age': int.parse(_ageController.text),
    'gender': _gender,
    'phone': _phoneController.text,
    'email': _emailController.text,
  });


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account created successfully!")),
      );

      _clearFields(); // Clear fields after successful registration
      Navigator.pop(context); // Go back to login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
      _clearFields(); // Clear fields after failed registration
    }
  } else {
    setState(() {}); // This will trigger the field validation highlighting
  }
}


  void _clearFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _ageController.clear();
    _gender = null; // Reset gender selection
    _phoneController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _passwordError = null; // Reset password error message
  }

  // Email validation
  String? _validateEmail(String? value) {
    if (value!.isEmpty) {
      return "Email is required";
    }
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return "Invalid email format";
    }
    return null;
  }

  // Phone number validation
  String? _validatePhone(String? value) {
    if (value!.isEmpty) {
      return "Phone number is required";
    }
    final RegExp phoneRegex = RegExp(r'^[0-9]{10,15}$'); // Adjust for valid phone number format
    if (!phoneRegex.hasMatch(value)) {
      return "Invalid phone number format";
    }
    return null;
  }

  // Age validation
  String? _validateAge(String? value) {
    if (value!.isEmpty) {
      return "Age is required";
    }
    final age = int.tryParse(value);
    if (age == null || age <= 0) {
      return "Enter a valid age";
    }
    return null;
  }

  // Password validation
  String? _validatePassword(String? value) {
    if (value!.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    // Add listeners to check if the form is filled
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _ageController.addListener(() => setState(() {}));
    _phoneController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
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
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.travel_explore, size: 80, color: Colors.teal),
                  SizedBox(height: 20),
                  Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                  SizedBox(height: 10),
                  Text('Join us for an amazing journey', style: TextStyle(fontSize: 16, color: Colors.teal[800])),
                  SizedBox(height: 30),

                  // Form Fields
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    validator: (value) => value!.isEmpty ? "First name is required" : null,
                  ),
                  SizedBox(height: 15),

                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    validator: (value) => value!.isEmpty ? "Last name is required" : null,
                  ),
                  SizedBox(height: 15),

                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: _validateAge,
                  ),
                  SizedBox(height: 15),

                  // Compact Gender Dropdown
                  DropdownButtonFormField<String>(
                    value: _gender,
                    isDense: true, // Makes the dropdown more compact
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      prefixIcon: Icon(Icons.person_pin),
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _gender = newValue;
                      });
                    },
                    validator: (value) => value == null ? "Gender is required" : null,
                  ),
                  SizedBox(height: 15),

                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: _validatePhone,
                  ),
                  SizedBox(height: 15),

                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: 15),

                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  SizedBox(height: 15),

                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                      focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Confirmation password is required";
                      }
                      if (value != _passwordController.text) {
                        return "Passwords do not match"; // Check if passwords match
                      }
                      return null;
                    },
                  ),
                  // Display password error message if applicable
                  if (_passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _passwordError!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text('Register', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Already have an account? Sign in here!', style: TextStyle(fontSize: 16, color: Colors.teal[700], fontWeight: FontWeight.w500)),
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

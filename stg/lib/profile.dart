import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  Future<Map<String, dynamic>?> _getUserProfile() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('tourist')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    return userDoc.data() as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          var userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Name: ${userData['firstName']} ${userData['lastName']}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Email: ${userData['email']}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Phone: ${userData['phone']}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Gender: ${userData['gender']}",
                    style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text("Age: ${userData['age']}", style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
    );
  }
}

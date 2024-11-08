import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationsPage extends StatelessWidget {
  final String stateName;
  final String categoryName;

  LocationsPage({required this.stateName, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$categoryName in $stateName'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('locations')
            .where('State', isEqualTo: stateName)
            .where('Category', isEqualTo: categoryName)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No locations found in this category.'));
          }

          // Retrieve locations
          List<DocumentSnapshot> locations = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              var location = locations[index];
              return Card(
                margin: EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(location['Location']),
                  trailing: Icon(Icons.location_on, color: Colors.teal),
                  onTap: () {
                    // Navigate to detailed location page if needed
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

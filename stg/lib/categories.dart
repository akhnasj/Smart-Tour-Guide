import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'locations.dart'; // Import LocationsPage to navigate to it

class CategoriesPage extends StatelessWidget {
  final String stateName;

  CategoriesPage({required this.stateName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$stateName - Categories'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('locations')
            .where('State', isEqualTo: stateName)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No categories found for this state.'));
          }

          // Extract unique categories from documents
          List<String> categories = snapshot.data!.docs
              .map((doc) => doc['Category'] as String)
              .toSet()
              .toList();

          return GridView.builder(
            padding: EdgeInsets.all(16.0),
            itemCount: categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              String category = categories[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to LocationsPage with selected category and state
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationsPage(
                        stateName: stateName,
                        categoryName: category,
                      ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.teal[100 * ((index % 5) + 1)],
                  child: Center(
                    child: Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

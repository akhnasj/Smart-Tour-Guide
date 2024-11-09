import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationsPage extends StatelessWidget {
  final String stateName;
  final String categoryName;

  LocationsPage({required this.stateName, required this.categoryName});

  Future<double?> getAverageRating(String locationId) async {
    // Fetch all reviews for the given location and calculate the average rating
    try {
      QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('l_id', isEqualTo: locationId)
          .get();

      if (reviewsSnapshot.docs.isEmpty) return null;

      double totalRating = reviewsSnapshot.docs.fold(
        0.0,
        (sum, doc) => sum + double.parse(doc['Rating']),
      );

      return totalRating / reviewsSnapshot.docs.length;
    } catch (e) {
      print("Error fetching reviews: $e");
      return null;
    }
  }

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
              String locationName = location['Location'];
              String city = location['City'] ?? 'Unknown City';
              String bestTimeToVisit =
                  location['Best Time to visit'] ?? 'All year';
              String type = location['Type'] ?? 'Unknown Type';
              String locationId = location['l_id'];

              return FutureBuilder<double?>(
                future: getAverageRating(locationId),
                builder: (context, ratingSnapshot) {
                  double? rating = ratingSnapshot.data;

                  return Card(
                    margin: EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16.0),
                      title: Text(
                        locationName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[900],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(
                            'City: $city',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Type: $type',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Best Time to Visit: $bestTimeToVisit',
                            style: TextStyle(fontSize: 16),
                          ),
                          if (rating != null) SizedBox(height: 4),
                          if (rating != null)
                            Text(
                              'Rating: ${rating.toStringAsFixed(1)} / 5.0',
                              style: TextStyle(fontSize: 16),
                            ),
                        ],
                      ),
                      trailing: Icon(Icons.location_on, color: Colors.teal),
                      onTap: () {
                        // Navigate to a detailed location page if needed
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

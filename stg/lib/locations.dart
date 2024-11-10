import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'locations_details.dart'; // Import the LocationsDetailsPage

class LocationsPage extends StatelessWidget {
  final String stateName;
  final String categoryName;

  LocationsPage({required this.stateName, required this.categoryName});

  Future<double?> getAverageRating(String locationId) async {
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

              Map<String, dynamic> locationData =
                  location.data() as Map<String, dynamic>;
              String? imageUrl = locationData.containsKey('Image_URL')
                  ? locationData['Image_URL']
                  : null;

              return FutureBuilder<double?>(
                future: getAverageRating(locationId),
                builder: (context, ratingSnapshot) {
                  double? rating = ratingSnapshot.data;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to LocationsDetailsPage on tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationsDetailsPage(
                            locationId: locationId,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (imageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                              child: Image.network(
                                imageUrl,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: Center(
                                      child: Text(
                                        'Image not available',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location Name in large, bold font
                                Text(
                                  locationName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal[800],
                                  ),
                                ),
                                SizedBox(height: 12),
                                // Row for city, type, best time to visit, and rating
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Left Column: City and Type
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'City:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.teal[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          city,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Type:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.teal[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          type,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Right Column: Best Time to Visit and Rating
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Best Time to Visit:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.teal[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          bestTimeToVisit,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        if (rating != null)
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Rating as stars
                                              RatingBar.builder(
                                                initialRating: rating,
                                                minRating: 1,
                                                itemSize: 24,
                                                direction: Axis.horizontal,
                                                allowHalfRating: true,
                                                itemCount: 5,
                                                itemBuilder: (context, _) =>
                                                    Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                onRatingUpdate: (rating) {},
                                              ),
                                              SizedBox(height: 4),
                                              // Rating text
                                              Text(
                                                '${rating.toStringAsFixed(1)} / 5.0',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.teal,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

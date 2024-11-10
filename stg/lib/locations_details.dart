import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class LocationsDetailsPage extends StatelessWidget {
  final String locationId;

  LocationsDetailsPage({required this.locationId});

  // Fetch location details
  Future<Map<String, dynamic>?> getLocationDetails() async {
    try {
      DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance
          .collection('locations')
          .doc(locationId)
          .get();

      if (locationSnapshot.exists) {
        return locationSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching location details: $e");
      return null;
    }
  }

  // Fetch reviews for the location
  Future<List<DocumentSnapshot>> getReviews() async {
    try {
      QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('l_id', isEqualTo: locationId)
          .get();

      return reviewsSnapshot.docs;
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }

  // Fetch average rating of the location
  Future<double?> getAverageRating() async {
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

  // Fetch full name of the tourist using t_id
  Future<String> getTouristName(String touristId) async {
    try {
      DocumentSnapshot touristSnapshot = await FirebaseFirestore.instance
          .collection('tourist')
          .doc(touristId)
          .get();

      if (touristSnapshot.exists) {
        Map<String, dynamic> touristData =
            touristSnapshot.data() as Map<String, dynamic>;
        String firstName = touristData['firstName'] ?? 'Unknown';
        String lastName = touristData['lastName'] ?? 'Unknown';
        return '$firstName $lastName'; // Return the full name
      }
      return 'Unknown'; // If tourist not found, return unknown
    } catch (e) {
      print("Error fetching tourist name: $e");
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Details"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        // Fetch location details
        future: getLocationDetails(),
        builder: (context, locationSnapshot) {
          if (locationSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!locationSnapshot.hasData || locationSnapshot.data == null) {
            return Center(child: Text("Location not found"));
          }

          Map<String, dynamic> location = locationSnapshot.data!;

          String locationName = location['Location'];
          String city = location['City'] ?? 'Unknown City';
          String type = location['Type'] ?? 'Unknown Type';
          String? imageUrl = location['Image_URL'];
          String locationId = location['l_id'];

          return FutureBuilder<double?>(
            // Fetch average rating
            future: getAverageRating(),
            builder: (context, ratingSnapshot) {
              double? rating = ratingSnapshot.data;

              return SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
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
                    SizedBox(height: 16),
                    // Location Name
                    Text(
                      locationName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    // Location details: City and Type
                    Text(
                      'City: $city',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Type: $type',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                    SizedBox(height: 16),
                    if (rating != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating as stars
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBar.builder(
                                initialRating: rating,
                                minRating: 1,
                                itemSize: 24,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {},
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${rating.toStringAsFixed(1)} / 5.0',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.teal),
                              ),
                            ],
                          ),
                          // Heart icon for favorites
                          IconButton(
                            onPressed: () {
                              // Add functionality to mark as favorite
                              print('Location added to favorites');
                            },
                            icon: Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                              size: 32,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 16),
                    // Reviews
                    FutureBuilder<List<DocumentSnapshot>>(
                      future: getReviews(),
                      builder: (context, reviewsSnapshot) {
                        if (reviewsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (reviewsSnapshot.data == null ||
                            reviewsSnapshot.data!.isEmpty) {
                          return Center(child: Text("No reviews yet"));
                        }

                        List<DocumentSnapshot> reviews = reviewsSnapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: reviews.map((reviewDoc) {
                            String reviewText =
                                reviewDoc['Review'] ?? 'No review';
                            String reviewerId = reviewDoc['t_id'];
                            double reviewRating =
                                double.parse(reviewDoc['Rating']);

                            return FutureBuilder<String>(
                              future: getTouristName(reviewerId),
                              builder: (context, touristSnapshot) {
                                if (touristSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox
                                      .shrink(); // Wait until data is fetched
                                }

                                if (touristSnapshot.hasData) {
                                  String reviewerName = touristSnapshot.data!;

                                  return Card(
                                    margin: EdgeInsets.only(bottom: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reviewerName, // Display full name
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.teal[800],
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            reviewText,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(height: 8),
                                          RatingBar.builder(
                                            initialRating: reviewRating,
                                            minRating: 1,
                                            itemSize: 20,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {},
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                return SizedBox.shrink(); // In case of no data
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

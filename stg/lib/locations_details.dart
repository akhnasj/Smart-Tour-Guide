import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_reviews.dart'; // Ensure you import the RatingsReviewsPage
import 'descriptions.dart'; // Import the Descriptions page
import 'weather.dart'; // Import the Weather page

class LocationsDetailsPage extends StatefulWidget {
  final String locationId;

  LocationsDetailsPage({required this.locationId});

  @override
  _LocationsDetailsPageState createState() => _LocationsDetailsPageState();
}

class _LocationsDetailsPageState extends State<LocationsDetailsPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  // Fetch location details
  Future<Map<String, dynamic>?> getLocationDetails() async {
    try {
      DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance
          .collection('locations')
          .doc(widget.locationId)
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
          .where('l_id', isEqualTo: widget.locationId)
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
          .where('l_id', isEqualTo: widget.locationId)
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

  // Check if the location is already marked as favorite for the logged-in user
  Future<void> checkIfFavorite() async {
    String? touristId = FirebaseAuth.instance.currentUser?.uid;

    if (touristId != null) {
      try {
        QuerySnapshot favouriteSnapshot = await FirebaseFirestore.instance
            .collection('favourites')
            .where('t_id', isEqualTo: touristId)
            .where('l_id', isEqualTo: widget.locationId)
            .get();

        setState(() {
          isFavorite = favouriteSnapshot.docs.isNotEmpty;
        });
      } catch (e) {
        print("Error checking favorite status: $e");
      }
    }
  }

  // Toggle favorite status and save to Firestore
  Future<void> toggleFavorite() async {
    String? touristId = FirebaseAuth.instance.currentUser?.uid;

    if (touristId != null) {
      try {
        if (isFavorite) {
          // Remove from favorites
          QuerySnapshot favouriteSnapshot = await FirebaseFirestore.instance
              .collection('favourites')
              .where('t_id', isEqualTo: touristId)
              .where('l_id', isEqualTo: widget.locationId)
              .get();

          for (var doc in favouriteSnapshot.docs) {
            await doc.reference.delete();
          }
        } else {
          // Add to favorites
          DocumentReference favouriteRef = FirebaseFirestore.instance
              .collection('favourites')
              .doc(); // Create a new document ID

          await favouriteRef.set({
            't_id': touristId,
            'l_id': widget.locationId,
            'f_id': favouriteRef.id, // Use document ID as unique f_id
          });
        }

        // After toggle, update the favorite status
        setState(() {
          isFavorite = !isFavorite;
        });
      } catch (e) {
        print("Error toggling favorite: $e");
      }
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
                    // Rating or Favorite Button
                    Row(
                      mainAxisAlignment: rating == null
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.spaceBetween,
                      children: [
                        if (rating != null) ...[
                          // Rating as stars
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBar.builder(
                                initialRating: rating,
                                minRating: 1,
                                itemSize: 20, // Reduced size of stars
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
                        ],
                        // Heart icon for favorites (always visible)
                        IconButton(
                          onPressed: toggleFavorite,
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Description Button
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DescriptionsPage(
                                  locationId: widget.locationId,
                                ),
                              ),
                            );
                          },
                          child: Text("View Description"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Weather Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeatherPage(
                                  city: city,
                                ),
                              ),
                            );
                          },
                          child: Text("View Weather"),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.teal,
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.teal, width: 2),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // Reviews section
                    FutureBuilder<List<DocumentSnapshot>>(
                      future: getReviews(),
                      builder: (context, reviewSnapshot) {
                        if (reviewSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!reviewSnapshot.hasData ||
                            reviewSnapshot.data!.isEmpty) {
                          return Center(child: Text("No reviews yet"));
                        }

                        List<DocumentSnapshot> reviews = reviewSnapshot.data!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: reviews.map((review) {
                            return ListTile(
                              title: FutureBuilder<String>(
                                future: getTouristName(review['t_id']),
                                builder: (context, touristSnapshot) {
                                  if (touristSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text("Loading...");
                                  }

                                  return Text(touristSnapshot.data ??
                                      'Unknown Tourist');
                                },
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        double.parse(review['Rating']),
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
                                  SizedBox(height: 8),
                                  Text(
                                    review['Review'],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    // Add a Rating and Review Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddReviewsPage(
                              locationId: widget.locationId,
                              city: city, // Pass the city for review
                            ),
                          ),
                        );
                      },
                      child: Text("Add a Rating and Review"),
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

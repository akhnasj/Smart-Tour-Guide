import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_reviews.dart'; // Ensure you import the RatingsReviewsPage
import 'descriptions.dart'; // Import the Descriptions page
import 'weather.dart'; // Import the Weather page (ensure you have this file)

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
                    Text(
                      locationName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 8),
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
                    Row(
                      mainAxisAlignment: rating == null
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.spaceBetween,
                      children: [
                        if (rating != null) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RatingBar.builder(
                                initialRating: rating,
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
                              SizedBox(height: 4),
                              Text(
                                '${rating.toStringAsFixed(1)} / 5.0',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.teal),
                              ),
                            ],
                          ),
                        ],
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DescriptionsPage(
                                    locationId: widget.locationId),
                              ),
                            );
                          },
                          child: Text('View Description'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WeatherPage(
                                  locationId: widget.locationId,
                                  city: city,
                                ),
                              ),
                            );
                          },
                          child: Text('View Weather'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews : ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.teal,
                              side: BorderSide(color: Colors.teal),
                            ),
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
                            child: Text('Add a Review'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    FutureBuilder<List<DocumentSnapshot>>(
                      future: getReviews(),
                      builder: (context, reviewsSnapshot) {
                        if (reviewsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        List<DocumentSnapshot> reviews = reviewsSnapshot.data!;

                        if (reviews.isEmpty) {
                          return Text('No reviews yet');
                        }

                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: reviews.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot review = reviews[index];
                            String reviewText = review['Review'];
                            double reviewRating =
                                double.parse(review['Rating']);
                            String touristId = review['t_id'];

                            return FutureBuilder<String>(
                              future: getTouristName(touristId),
                              builder: (context, nameSnapshot) {
                                String name = nameSnapshot.data ?? 'Anonymous';

                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 8.0),
                                  child: ListTile(
                                    title: Text(
                                      name,
                                      style: TextStyle(
                                          fontWeight: FontWeight
                                              .bold), // Make name bold
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                        SizedBox(height: 4),
                                        Text(reviewText),
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

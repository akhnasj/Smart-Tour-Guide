// reviews.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ReviewsList extends StatelessWidget {
  final String locationId;
  final Future<List<DocumentSnapshot>> Function() getReviews;
  final Future<String> Function(String) getTouristName;

  ReviewsList({
    required this.locationId,
    required this.getReviews,
    required this.getTouristName,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: getReviews(),
      builder: (context, reviewSnapshot) {
        if (reviewSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (reviewSnapshot.data == null || reviewSnapshot.data!.isEmpty) {
          return Center(child: Text("No reviews yet"));
        }

        List<DocumentSnapshot> reviews = reviewSnapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: reviews.map((review) {
            return FutureBuilder<String>(
              future: getTouristName(review['t_id']),
              builder: (context, touristSnapshot) {
                String touristName = touristSnapshot.data ?? 'Unknown';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          touristName,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          review['Review'] ?? 'No review',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        SizedBox(height: 4),
                        RatingBar.builder(
                          initialRating: double.parse(review['Rating']),
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
              },
            );
          }).toList(),
        );
      },
    );
  }
}

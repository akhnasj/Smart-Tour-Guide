import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingsReviewsPage extends StatefulWidget {
  final String locationId;
  final String city;

  RatingsReviewsPage({required this.locationId, required this.city});

  @override
  _RatingsReviewsPageState createState() => _RatingsReviewsPageState();
}

class _RatingsReviewsPageState extends State<RatingsReviewsPage> {
  double _rating = 3.0; // Default rating
  TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  // Submit review to Firestore
  Future<void> submitReview() async {
    String? touristId = FirebaseAuth.instance.currentUser?.uid;
    if (touristId == null) {
      // Handle case when user is not logged in
      print("Error: Tourist not logged in");
      return;
    }

    String reviewText = _reviewController.text.trim();
    if (reviewText.isEmpty) {
      // Show an error if review text is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a review")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Generate a unique document ID for the review
      DocumentReference reviewRef =
          FirebaseFirestore.instance.collection('reviews').doc();
      await reviewRef.set({
        'l_id': widget.locationId, // Location ID
        't_id': touristId, // Tourist ID
        'r_id': reviewRef.id, // Unique review ID (document ID)
        'Review': reviewText, // Review text
        'Rating': _rating.toString(), // Rating as a string
        'City': widget.city, // City of the location
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review added successfully!")),
      );
      Navigator.pop(context); // Close the review page after submission
    } catch (e) {
      print("Error submitting review: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a Rating & Review"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Rate this location:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            SizedBox(height: 10),
            // Rating bar for user to select rating
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              "Your Review:",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            SizedBox(height: 10),
            // Text field for entering review
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your review here...",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Submit button
            _isSubmitting
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: submitReview,
                    child: Text("Submit Review"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // Button color
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

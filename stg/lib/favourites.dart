import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stg/locations_details.dart';

class FavouritesPage extends StatefulWidget {
  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  // Fetch all favourite locations for the logged-in user
  Future<List<Map<String, dynamic>>> getFavoriteLocations() async {
    String? touristId = FirebaseAuth.instance.currentUser?.uid;

    if (touristId == null) {
      return [];
    }

    try {
      // Fetch the favorite locations from the 'favourites' collection where t_id is the tourist's id
      QuerySnapshot favouritesSnapshot = await FirebaseFirestore.instance
          .collection('favourites')
          .where('t_id', isEqualTo: touristId)
          .get();

      List<Map<String, dynamic>> favouriteLocations = [];

      for (var favDoc in favouritesSnapshot.docs) {
        String locationId = favDoc['l_id'];

        // Fetch the location details from the 'locations' collection using l_id
        DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance
            .collection('locations')
            .doc(locationId)
            .get();

        if (locationSnapshot.exists) {
          favouriteLocations
              .add(locationSnapshot.data() as Map<String, dynamic>);
        }
      }

      return favouriteLocations;
    } catch (e) {
      print("Error fetching favorite locations: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Favourites"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getFavoriteLocations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No favorite locations yet"));
          }

          List<Map<String, dynamic>> favouriteLocations = snapshot.data!;

          return ListView.builder(
            itemCount: favouriteLocations.length,
            itemBuilder: (context, index) {
              var location = favouriteLocations[index];
              String locationName = location['Location'] ?? 'Unknown Location';
              String city = location['City'] ?? 'Unknown City';
              String type = location['Type'] ?? 'Unknown Type';
              String? imageUrl = location['Image_URL'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              );
                            },
                          ),
                        )
                      : Icon(Icons.image_not_supported),
                  title: Text(locationName),
                  subtitle: Text('City: $city\nType: $type'),
                  onTap: () {
                    // Navigate to the location details page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationsDetailsPage(
                          locationId: location['l_id'], // Pass the location ID
                        ),
                      ),
                    );
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

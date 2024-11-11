import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'chat_page.dart'; // Import the new chat page

class SharingDetailsPage extends StatefulWidget {
  final String userId;

  SharingDetailsPage({required this.userId});

  @override
  _SharingDetailsPageState createState() => _SharingDetailsPageState();
}

class _SharingDetailsPageState extends State<SharingDetailsPage> {
  // Fetch the favorite locations of the user
  Future<List<Map<String, dynamic>>> getLocationDetails(String userId) async {
    try {
      // Fetch the user's favorite locations from the favourites collection
      QuerySnapshot favouritesSnapshot = await FirebaseFirestore.instance
          .collection('favourites')
          .where('t_id', isEqualTo: userId)
          .get();

      List<String> locationIds =
          favouritesSnapshot.docs.map((doc) => doc['l_id'] as String).toList();

      if (locationIds.isEmpty) {
        return [];
      }

      // Fetch the locations from the locations collection using the l_id
      QuerySnapshot locationsSnapshot = await FirebaseFirestore.instance
          .collection('locations')
          .where('l_id', whereIn: locationIds)
          .get();

      List<Map<String, dynamic>> locations = [];

      for (var doc in locationsSnapshot.docs) {
        locations.add(doc.data() as Map<String, dynamic>);
      }

      return locations;
    } catch (e) {
      print("Error fetching location details: $e");
      return [];
    }
  }

  /*  // Method to initiate chat with the selected tourist
  void startChat(String otherUserId) {
    // Create a chat room id (using both user IDs to ensure uniqueness)
    String chatRoomId = [widget.userId, otherUserId].join('_');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatRoomId: chatRoomId,
          currentUserId: widget.userId,
          otherUserId: otherUserId,
        ),
      ),
    );
  }
 */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shared Favorite Locations"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getLocationDetails(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No shared locations found"));
          }

          List<Map<String, dynamic>> locations = snapshot.data!;

          return ListView.builder(
            itemCount: locations.length,
            itemBuilder: (context, index) {
              var location = locations[index];
              String locationName = location['Location'] ?? 'No name available';
              String bestTime =
                  location['Best Time to visit'] ?? 'No information';
              String category = location['Category'] ?? 'No category';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(locationName),
                  subtitle: Text('Best Time: $bestTime\nCategory: $category'),
                  onTap: () {
                    // Optionally, you can add more details here
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.chat),
                    onPressed: () {
                      // Start chat with the selected user
                      // startChat(location['t_id']);
                    },
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

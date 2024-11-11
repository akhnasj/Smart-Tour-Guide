import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sharing_details.dart'; // Import the new SharingDetailsPage
import 'chat_page.dart'; // Import the ChatPage

class PeoplesPage extends StatefulWidget {
  @override
  _PeoplesPageState createState() => _PeoplesPageState();
}

class _PeoplesPageState extends State<PeoplesPage> {
  // Fetch people who share similar favorite locations
  Future<List<Map<String, dynamic>>> getSimilarFavoritePeople() async {
    String? touristId = FirebaseAuth.instance.currentUser?.uid;

    if (touristId == null) {
      return [];
    }

    try {
      // Fetch the favorite locations for the current user
      QuerySnapshot favouritesSnapshot = await FirebaseFirestore.instance
          .collection('favourites')
          .where('t_id', isEqualTo: touristId)
          .get();

      List<String> favoriteLocationIds =
          favouritesSnapshot.docs.map((doc) => doc['l_id'] as String).toList();

      if (favoriteLocationIds.isEmpty) {
        return [];
      }

      // Now fetch users who have the same favorite location
      QuerySnapshot similarUsersSnapshot = await FirebaseFirestore.instance
          .collection('favourites')
          .where('l_id', whereIn: favoriteLocationIds)
          .get();

      List<Map<String, dynamic>> similarPeople = [];

      for (var doc in similarUsersSnapshot.docs) {
        String userId = doc['t_id'];
        if (userId != touristId) {
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('tourist')
              .doc(userId)
              .get();

          if (userSnapshot.exists) {
            similarPeople.add(userSnapshot.data() as Map<String, dynamic>);
          }
        }
      }

      return similarPeople;
    } catch (e) {
      print("Error fetching similar people: $e");
      return [];
    }
  }

  // Method to initiate chat with the selected tourist
  void startChat(String otherUserId) {
    if (otherUserId.isEmpty) return; // Ensure the userId is not empty

    // Create a consistent chat room ID (by sorting the user IDs to ensure consistency)
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    List<String> userIds = [currentUserId, otherUserId];
    userIds
        .sort(); // This ensures the chat room ID is the same regardless of the order

    String chatRoomId =
        userIds.join('_'); // Create a single, consistent chat room ID

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatRoomId: chatRoomId,
          currentUserId: currentUserId,
          otherUserId: otherUserId,
        ),
      ),
    );
  }

/* 
  // Method to initiate chat with the selected tourist
  void startChat(String otherUserId) {
    if (otherUserId.isEmpty) return; // Ensure the userId is not empty

    // Create a chat room id (using both user IDs to ensure uniqueness)
    String chatRoomId =
        [FirebaseAuth.instance.currentUser!.uid, otherUserId].join('_');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatRoomId: chatRoomId,
          currentUserId: FirebaseAuth.instance.currentUser!.uid,
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
        title: Text("People with Similar Favorites"),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getSimilarFavoritePeople(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No one shares your favorite locations"));
          }

          List<Map<String, dynamic>> similarPeople = snapshot.data!;

          return ListView.builder(
            itemCount: similarPeople.length,
            itemBuilder: (context, index) {
              var person = similarPeople[index];
              String name = "${person['firstName']} ${person['lastName']}";
              String email = person['email'] ?? 'No email provided';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text(name),
                  subtitle: Text(email),
                  onTap: () {
                    // Navigate to SharingDetailsPage when card is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SharingDetailsPage(
                          userId: person[
                              't_id'], // Pass the userId to SharingDetailsPage
                        ),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.chat),
                    onPressed: () {
                      // Start chat with the selected user
                      startChat(person['t_id']);
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

// explore.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'categories.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String searchQuery = "";
  List<String> uniqueStates = [];
  List<String> filteredStates = [];

  final Map<String, String> stateDescriptions = {
    'Andaman and Nicobar Islands': 'Tropical paradise with beaches.',
    'Andhra Pradesh': 'Home to Tirupati and beautiful beaches.',
    'Arunachal Pradesh': 'Untouched beauty and hills.',
    //... Add all descriptions for each state
    'West Bengal': 'Cultural heritage and Kolkata city.',
  };

  @override
  void initState() {
    super.initState();
    fetchUniqueStates();
  }

  // Fetch unique state names from Firestore
  void fetchUniqueStates() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('locations').get();
    final states =
        snapshot.docs.map((doc) => doc['State'] as String).toSet().toList();
    setState(() {
      uniqueStates = states;
      filteredStates = states;
    });
  }

  // Filter states based on search query
  void filterStates(String query) {
    setState(() {
      searchQuery = query;
      filteredStates = uniqueStates
          .where((state) => state.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                onChanged: filterStates,
                decoration: InputDecoration(
                  hintText: 'Search states or UTs',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
              ),
            ),
            // ListView for displaying filtered states
            Expanded(
              child: ListView.builder(
                itemCount: filteredStates.length,
                itemBuilder: (context, index) {
                  String stateName = filteredStates[index];
                  String stateDescription = stateDescriptions[stateName] ??
                      'Explore the beauty of $stateName!';
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        stateName,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800]),
                      ),
                      subtitle: Text(stateDescription),
                      leading: Icon(Icons.location_city, color: Colors.teal),
                      trailing: Icon(Icons.arrow_forward, color: Colors.teal),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoriesPage(stateName: stateName),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

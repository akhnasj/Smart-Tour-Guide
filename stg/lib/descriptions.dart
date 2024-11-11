import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class DescriptionsPage extends StatefulWidget {
  final String locationId;

  DescriptionsPage({required this.locationId});

  @override
  _DescriptionsPageState createState() => _DescriptionsPageState();
}

class _DescriptionsPageState extends State<DescriptionsPage> {
  late String locationName;
  bool isLoading = true;
  String description = '';

  @override
  void initState() {
    super.initState();
    fetchLocationDescription();
  }

  // Fetch description from Wikipedia, fallback to Wikidata if Wikipedia fails
  Future<void> fetchLocationDescription() async {
    try {
      final locationSnapshot = await FirebaseFirestore.instance
          .collection('locations')
          .doc(widget.locationId)
          .get();

      if (locationSnapshot.exists) {
        locationName = locationSnapshot['Location'];
        String cityName = locationSnapshot['City'];

        // Try fetching from Wikipedia API first
        final wikipediaResponse = await http.get(
          Uri.parse(
              'https://en.wikipedia.org/w/api.php?action=query&prop=extracts&exintro&explaintext&titles=$locationName&format=json'),
        );

        if (wikipediaResponse.statusCode == 200) {
          final wikipediaData = json.decode(wikipediaResponse.body);
          final pages = wikipediaData['query']['pages'];
          final pageId = pages.keys.first;
          final pageDescription = pages[pageId]['extract'];

          // Check if Wikipedia data is found
          if (pageDescription != null && pageDescription.isNotEmpty) {
            setState(() {
              description = pageDescription;
              isLoading = false;
            });
            return; // Exit if Wikipedia data was found
          }
        }

        // If no Wikipedia data found, fetch from Wikidata API
        final wikidataSearchResponse = await http.get(
          Uri.parse(
              'https://www.wikidata.org/w/api.php?action=wbsearchentities&search=$locationName&language=en&format=json'),
        );

        if (wikidataSearchResponse.statusCode == 200) {
          final wikidataSearchData = json.decode(wikidataSearchResponse.body);

          if (wikidataSearchData['search'].isNotEmpty) {
            final entityId = wikidataSearchData['search'][0]['id'];

            // Fetch the description using the Wikidata entity ID
            final wikidataEntityResponse = await http.get(
              Uri.parse(
                  'https://www.wikidata.org/w/api.php?action=wbgetentities&ids=$entityId&props=descriptions&languages=en&format=json'),
            );

            if (wikidataEntityResponse.statusCode == 200) {
              final entityData = json.decode(wikidataEntityResponse.body);
              final entityDescription = entityData['entities'][entityId]
                  ['descriptions']['en']['value'];

              setState(() {
                description = entityDescription ?? 'No description available.';
                isLoading = false;
              });
            } else {
              throw Exception('Failed to load Wikidata entity description');
            }
          } else {
            setState(() {
              description = 'No description available for this location.';
              isLoading = false;
            });
          }
        } else {
          throw Exception('Failed to search Wikidata');
        }
      } else {
        setState(() {
          description = 'Location not found in database.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        description = 'Error fetching description: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Description"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description of $locationName',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      description,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

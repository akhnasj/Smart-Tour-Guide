import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DescriptionsPage extends StatefulWidget {
  final String locationId;

  DescriptionsPage({required this.locationId});

  @override
  _DescriptionsPageState createState() => _DescriptionsPageState();
}

class _DescriptionsPageState extends State<DescriptionsPage> {
  late Future<String> _description;

  @override
  void initState() {
    super.initState();
    _description = fetchDescription();
  }

  Future<String> fetchDescription() async {
    final String locationId = widget.locationId;

    // Define the Wikipedia API URL
    final url = Uri.parse('https://en.wikipedia.org/w/api.php?' +
        'action=query&format=json&prop=extracts&exintro=&explaintext=&titles=$locationId');

    try {
      // Send GET request to Wikipedia API
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> data = json.decode(response.body);

        // Extract the page ID from the response
        final pages = data['query']['pages'];
        final pageId = pages.keys.first;

        // Extract the description (extract)
        final description =
            pages[pageId]['extract'] ?? 'No description available';

        return description;
      } else {
        throw Exception('Failed to load description');
      }
    } catch (e) {
      print('Error: $e');
      return 'Failed to fetch description';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Description'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<String>(
        future: _description,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching description'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No description available'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description of ${widget.locationId}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[800],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    snapshot.data!,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

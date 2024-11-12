import 'package:flutter/material.dart';

class MapsPage extends StatelessWidget {
  final String city;

  MapsPage({required this.city, required String locationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map of $city"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Text("Map for $city will be displayed here."),
        // Add your map integration here (e.g., using Google Maps SDK)
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _locationNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _bestTimeController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  bool _isSubmitting = false;
  int _selectedIndex = 0; // Set to 0 to load welcome screen first

  // Add a new location
  Future<void> addLocation() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      String locationName = _locationNameController.text.trim();
      String category = _categoryController.text.trim();
      String city = _cityController.text.trim();
      String state = _stateController.text.trim();
      String bestTime = _bestTimeController.text.trim();
      String type = _typeController.text.trim();
      String imageUrl = _imageUrlController.text.trim();

      if (locationName.isEmpty ||
          category.isEmpty ||
          city.isEmpty ||
          state.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all required fields")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('locations').add({
        'Location': locationName,
        'Category': category,
        'City': city,
        'State': state,
        'Best Time to Visit': bestTime,
        'Type': type,
        'Image_URL': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location added successfully!")),
      );
      _clearInputFields();
    } catch (e) {
      print("Error adding location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add location")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Clear input fields
  void _clearInputFields() {
    _locationNameController.clear();
    _categoryController.clear();
    _cityController.clear();
    _stateController.clear();
    _bestTimeController.clear();
    _typeController.clear();
    _imageUrlController.clear();
  }

  // Get locations organized by state
  Stream<QuerySnapshot> getLocationsByState() {
    return FirebaseFirestore.instance
        .collection('locations')
        .orderBy('State')
        .snapshots();
  }

  // Get reviews by locations
  Stream<QuerySnapshot> getReviews() {
    return FirebaseFirestore.instance.collection('reviews').snapshots();
  }

  // Sidebar options
  Widget _getSidebarContent() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.teal),
          child: Text(
            'Admin Panel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          title: Text('Welcome Page',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            setState(() {
              _selectedIndex = 0;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('Add Location',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('View Locations by State',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            setState(() {
              _selectedIndex = 2;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('View Ratings & Reviews',
              style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            setState(() {
              _selectedIndex = 3;
            });
            Navigator.pop(context);
          },
        ),
        ListTile(
          title: Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Page"),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: _getSidebarContent(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _selectedIndex == 0
            ? WelcomeAdminPage() // Display welcome screen
            : _selectedIndex == 1
                ? _buildAddLocationForm()
                : _selectedIndex == 2
                    ? _buildViewLocationsByState()
                    : _buildViewRatingsAndReviews(),
      ),
    );
  }

  // Add Location Form
  Widget _buildAddLocationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Add New Location",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _buildTextField(_locationNameController, "Location Name"),
        _buildTextField(_categoryController, "Category"),
        _buildTextField(_cityController, "City"),
        _buildTextField(_stateController, "State"),
        _buildTextField(_bestTimeController, "Best Time to Visit"),
        _buildTextField(_typeController, "Type"),
        _buildTextField(_imageUrlController, "Image URL"),
        SizedBox(height: 10),
        _isSubmitting
            ? Center(child: CircularProgressIndicator())
            : ElevatedButton(
                onPressed: addLocation,
                child: Text("Add Location"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
      ],
    );
  }

  // View Locations by State
  Widget _buildViewLocationsByState() {
    return StreamBuilder<QuerySnapshot>(
      stream: getLocationsByState(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var locations = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: locations.length,
          itemBuilder: (context, index) {
            var location = locations[index];
            return ListTile(
              title: Text(location['Location']),
              subtitle: Text(
                  "${location['Category']} - ${location['City']} (${location['State']})"),
            );
          },
        );
      },
    );
  }

  // View Ratings & Reviews
  Widget _buildViewRatingsAndReviews() {
    return StreamBuilder<QuerySnapshot>(
      stream: getReviews(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var reviews = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            var review = reviews[index];
            return ListTile(
              title: Text(review['Review']),
              subtitle:
                  Text("Rating: ${review['Rating']} | City: ${review['City']}"),
            );
          },
        );
      },
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration:
          InputDecoration(labelText: labelText, border: OutlineInputBorder()),
    );
  }
}

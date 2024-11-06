// class LocationDetailsPage extends StatelessWidget {
//   final String locationId;

//   LocationDetailsPage({required this.locationId});

//   Future<Map<String, dynamic>> fetchWeather(String locationName) async {
//     // Fetch weather data from your weather API here
//     // For example:
//     return {
//       "temperature": "22°C",
//       "conditions": "Sunny",
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Location Details')),
//       body: FutureBuilder(
//         future: FirebaseFirestore.instance
//             .collection('locations')
//             .doc(locationId)
//             .get(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return CircularProgressIndicator();
//           var location = snapshot.data.data();
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Image.network(location['image_url']),
//               Text(location['name'], style: TextStyle(fontSize: 24)),
//               Text('Type: ${location['type']}'),
//               Text('Best Time to Visit: ${location['best_time_to_visit']}'),
//               FutureBuilder(
//                 future: fetchWeather(location['name']),
//                 builder: (context, snapshot) {
//                   if (!snapshot.hasData) return Text("Fetching weather...");
//                   return Text(
//                       "Weather: ${snapshot.data['temperature']} - ${snapshot.data['conditions']}");
//                 },
//               ),
//               // Display map (Google Maps API or Flutter maps package)
//               // Display reviews
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class LocationsPage extends StatelessWidget {
//   final String category;

//   LocationsPage({required this.category});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('$category Locations')),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance
//             .collection('locations')
//             .where('category', isEqualTo: category)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return CircularProgressIndicator();
//           return ListView.builder(
//             itemCount: snapshot.data.docs.length,
//             itemBuilder: (context, index) {
//               var location = snapshot.data.docs[index];
//               return ListTile(
//                 title: Text(location['name']),
//                 subtitle: Text(location['best_time_to_visit']),
//                 leading: Image.network(location['image_url']),
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               LocationDetailsPage(locationId: location.id)));
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

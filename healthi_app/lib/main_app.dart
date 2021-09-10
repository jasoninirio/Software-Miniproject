// Home page screen

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text("Healthi - Home Page"),
      ),
    );
  }
}

// class HomePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('healthi'),
//         centerTitle: true,
//         backgroundColor: Colors.green,
//       ),
//       body: Center(
//         child: Column(
//           children: <Widget>[
//             // Camera Button
//             ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/camera');
//                 },
//                 child: Text('Camera')),

//             // Profile Button
//             ElevatedButton(
//                 onPressed: () {
//                   Navigator.pushNamed(context, '/profile');
//                 },
//                 child: Text('Profile')),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'dart:js'
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => HomePage(),
      '/camera': (context) => CameraPage(),
      '/profile': (context) => ProfilePage(),
    },
  ));
}

// Home Page - hosts some neat things like a calorie tracker (?)
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('healthi'),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Camera Button
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
                child: Text('Camera')),

            // Profile Button
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                child: Text('Profile')),
          ],
        ),
      ),
    );
  }
}

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

// Camera Page - hosts the camera and a search bar to add food items to User's food tracker
class _CameraPageState extends State<CameraPage> {
  String? scanResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('camera'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.amber, onPrimary: Colors.black),
              icon: Icon(Icons.camera_alt_outlined),
              label: Text('Start Scan'),
              onPressed: scanBarcode,
            ),
            SizedBox(height: 20),
            Text(
              scanResult == null
                  ? 'Scan a code!'
                  : 'Your scanned result: $scanResult',
              style: TextStyle(fontSize: 18),
            )
            // Back Button
            // ElevatedButton(
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     child: Text('Go Back')
            // ),
          ],
        ),
      ),
    );
  }

  Future scanBarcode() async {
    String scanResult;

    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      scanResult = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() => this.scanResult = scanResult);
  }
}

// Profile Page - Shows first and last name, recipes, and history stats of User's food items (?)
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('profile'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Back Button
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Go Back')),
          ],
        ),
      ),
    );
  }
}

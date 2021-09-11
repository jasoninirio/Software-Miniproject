// import 'dart:js'
// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:healthi_app/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init firebase
  await Firebase.initializeApp();

  // init app
  runApp(SignIn());
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
              scanResult == null ? 'Scan a code!' : 'Scan result: $scanResult',
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

class SignIn extends StatefulWidget {
  // SignIn({key? key}) : super(key: key);
  @override
  _SignIn_state createState() => _SignIn_state();
}

class _SignIn_state extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthi App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: LoginScreen(),
    );
  }
}

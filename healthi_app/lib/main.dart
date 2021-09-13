// import 'dart:js'
// import 'dart:html';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;

//Class for the relevant info extracted from the FDC rest API
class FoodInfo {
  final String gtinUpc;
  final int fdcId;
  final String description;
  final num calories;

  FoodInfo(
      {required this.gtinUpc,
      required this.fdcId,
      required this.description,
      required this.calories});

  factory FoodInfo.fromJson(Map<String, dynamic> json) {
    return FoodInfo(
        gtinUpc: json['foods'][0]['gtinUpc'],
        fdcId: json['foods'][0]['fdcId'],
        description: json['foods'][0]['description'],
        calories: json['foods'][0]['foodNutrients'][3]['value']);
  }
}

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
  String? scanResult = null;
  late Future<FoodInfo> futureFoodInfo;
  String myCode = '035107001247';

  @override
  void initState() {
    super.initState();

    // futureFoodInfo = fetchFoodInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Scan a Food Item!'),
          centerTitle: true,
          backgroundColor: Colors.tealAccent[700]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent[700], onPrimary: Colors.black),
              icon: Icon(Icons.camera_alt_outlined),
              label: Text('Start Scan'),
              onPressed: scanBarcode,
            ),
            SizedBox(height: 20),
            Text(
              scanResult == null
                  ? 'Scan a barcode first!'
                  : 'You scanned the barcode: $scanResult',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            Center(
              child: FutureBuilder<FoodInfo>(
                future: futureFoodInfo = fetchFoodInfo(scanResult.toString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData && scanResult != null) {
                    return Column(children: <Widget>[
                      Text(
                        'Food Item Name: ' +
                            (snapshot.data!.description).toString(),
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Barcode number: ' +
                            (snapshot.data!.gtinUpc).toString(),
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'FDC ID Number: ' + (snapshot.data!.fdcId).toString(),
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Calories: ' +
                            (snapshot.data!.calories).toString() +
                            ' calories',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      )
                    ]);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                },
              ),
            ),
            // //Back Button
            // ElevatedButton(
            //     onPressed: () {
            //       scanResult = null;
            //     },
            //     child: Text('Scan new item')),
          ],
        ),
      ),
    );
  }

  Future scanBarcode() async {
    String scanResult;

    try {
      scanResult = await FlutterBarcodeScanner.scanBarcode(
          "#6CEE5D", "Cancel", true, ScanMode.BARCODE);
    } on PlatformException {
      scanResult = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() => this.scanResult = scanResult);
  }

  Future<FoodInfo> fetchFoodInfo(String barcode) async {
    final response = await http.get(Uri.parse(
        'https://api.nal.usda.gov/fdc/v1/foods/search?&api_key=K5TALOAH4AWhPCKKbZsz1gIzRgnNuaC2OPB1lhsR&query=$barcode&dataType=Branded'));

    if (response.statusCode == 200) {
      return FoodInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load food info');
    }
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

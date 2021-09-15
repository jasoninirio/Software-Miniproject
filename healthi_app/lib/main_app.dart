// Home page screen
// import 'dart:js'
// import 'dart:html';
import 'dart:async';
import 'dart:core';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:healthi_app/login.dart';

// Connecting to Cloud Firestore for creating recipes, adding ingredients, etc.
final firestoreInstance = FirebaseFirestore.instance;

//Class for the relevant info extracted from the FDC rest API
class FoodInfoVar {
  static String food_desc = '';
  static num food_calories = 0;
}

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

class App_PageView extends StatefulWidget {
  @override
  _App_PageViewState createState() => _App_PageViewState();
}

class _App_PageViewState extends State<App_PageView> {
  PageController _controller = PageController(initialPage: 1);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        CameraPage(),
        HomePage(),
        ProfilePage(),
      ],
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text("this is the homepage"),
          ],
        ),
      ),
    );
  }
}

// Profile page - allows user to add recipes
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _textFieldController = TextEditingController();

  String? recipeName;
  String _chosenRecipe;
  var items = <String>[firestoreInstance.collection("Recipes").doc(UserLogin.idToken).get()];

  Future<void> _displayTextInputDialog(BuildContext context) async{
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add a Recipe'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  recipeName = value;
                });
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Recipe Name"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    if (recipeName != null)
                    {
                        firestoreInstance
                          .collection('Recipes')
                          .doc(UserLogin.idToken)
                          .update({
                        "${recipeName}": [],
                      });
                    }
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${UserLogin.firstName} ${UserLogin.lastName}'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            DropdownButton(
              value: _chosenRecipe,
              icon: Icon(Icons.keyboard_arrow_down),
              items:items.map<DropdownMenuItem<String>>((items) {
                    return DropdownMenuItem(
                        value: items,
                        child: Text(items)
                    );
                }).toList(),
              onChanged: (String value){
                setState(() {
                    _chosenRecipe = value;
                });
              },
            ),
            ElevatedButton(
                onPressed: () {
                  _displayTextInputDialog(context);
                },
                child: Text("Add Recipe")
            ),
          ],
        ),
      ),
    );
  }
}

// Camera page - has barcode scanner that calls FDC API
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

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
          backgroundColor: Colors.greenAccent[700]),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  primary: Colors.greenAccent[700], onPrimary: Colors.black),
              icon: Icon(Icons.camera_alt_outlined),
              label: Text('Start Scan', style: TextStyle(fontSize: 25)),
              onPressed: scanBarcode,
            ),
            SizedBox(height: 20),
            Text(
              scanResult == null
                  ? 'Scan a barcode first!'
                  : 'You scanned the barcode: $scanResult',
              style: TextStyle(fontSize: 23),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),
            Center(
              child: FutureBuilder<FoodInfo>(
                future: futureFoodInfo = fetchFoodInfo(scanResult.toString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData && scanResult != null) {
                    FoodInfoVar.food_calories = snapshot.data!.calories;
                    FoodInfoVar.food_desc = snapshot.data!.description;
                    firestoreInstance
                        .collection('History')
                        .doc(UserLogin.idToken)
                        .update({
                      "${FoodInfoVar.food_desc}": FoodInfoVar.food_calories,
                    });

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
                            ' kcal',
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

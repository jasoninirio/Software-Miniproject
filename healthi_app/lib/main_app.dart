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

// void setState(Null Function() param0) {}

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
    Stream<DocumentSnapshot> data = firestoreInstance
        .collection('History')
        .doc(UserLogin.idToken)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Food History'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent[700],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 15),
            Expanded(
              child: StreamBuilder(
                  stream: data,
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      var foodHistory = snapshot.data!;
                      var foodItems = foodHistory['Food'];

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: foodItems != null ? foodItems.length : 0,
                        itemBuilder: (_, int index) {
                          return Container(
                            height: 75,
                            margin: EdgeInsets.all(2),
                            color: Colors.lime[100],
                            child: Center(
                              child: Text(
                                "${foodItems[index]['Name']} - ${foodItems[index]['Calories']} KCal.",
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
            SizedBox(height: 15),
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
  Stream<DocumentSnapshot> rdata = firestoreInstance
      .collection('Recipes')
      .doc(UserLogin.idToken)
      .snapshots();
  TextEditingController _textFieldController = TextEditingController();

  String? recipeName;

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add a Recipe'),
            content: TextField(
              onChanged: (value) {
                recipeName = value;
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Recipe Name"),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.red,
                  textStyle: TextStyle(color: Colors.white),
                ),
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.green,
                  textStyle: TextStyle(color: Colors.white),
                ),
                child: Text('Add'),
                onPressed: () {
                  print("pressed");
                  if (recipeName != null || recipeName!.isEmpty) {
                    print("adding to firestore");

                    var recipeInfo = new Map<String, dynamic>();
                    recipeInfo = {
                      "Name": recipeName,
                      "Ingredients": [],
                      "Calories": 0
                    };

                    firestoreInstance
                        .collection('Recipes')
                        .doc(UserLogin.idToken)
                        .update({
                      "recipe": FieldValue.arrayUnion([recipeInfo])
                    });
                  } else {
                    print("null recipe name");
                  }
                  Navigator.pop(context);
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
        title: Text('Welcome, ${UserLogin.firstName} ${UserLogin.lastName}'),
        centerTitle: true,
        backgroundColor: Colors.greenAccent[700],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                  stream: rdata,
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      var recipes = snapshot.data!;
                      var items = recipes['recipe'];

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: items != null ? items.length : 0,
                        itemBuilder: (_, int index) {
                          final children = <Widget>[];
                          for (var i = 0;
                              i < items[index]['Ingredients'].length;
                              i++) {
                            children.add(new ListTile(
                              title: Text("${items[index]['Ingredients'][i]}"),
                            ));
                          }
                          // children.add(
                          //   new Container(
                          //       alignment: Alignment.bottomRight,
                          //       child: new FloatingActionButton(
                          //         onPressed: () {
                          //           Navigator.push(
                          //             context,
                          //             MaterialPageRoute(
                          //                 builder: (context) => CameraPage()),
                          //           );
                          //         },
                          //         backgroundColor: Colors.green,
                          //         child: Icon(Icons.add),
                          //       )),
                          // );
                          return ExpansionTile(
                            title: Text("${items[index]['Name']}"),
                            subtitle: Text(
                                "${items[index]['Calories'].toString()} KCal"),
                            children: children,
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  }),
            ),
            ElevatedButton(
              onPressed: () {
                _displayTextInputDialog(context);
              },
              style: ElevatedButton.styleFrom(primary: Colors.green),
              child: Text("Add Recipe"),
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
  String? scanResult;
  late Future<FoodInfo> futureFoodInfo;

  Future _addtoRecipe(BuildContext context) async {
    print("hello from add to recipe");
  }

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
                    print('Scanned item');
                    FoodInfoVar.food_calories = snapshot.data!.calories;
                    FoodInfoVar.food_desc = snapshot.data!.description;

                    var foodInfo = new Map<String, dynamic>();
                    foodInfo = {
                      "Name": "${FoodInfoVar.food_desc}",
                      "Calories": "${FoodInfoVar.food_calories}"
                    };

                    firestoreInstance
                        .collection('History')
                        .doc(UserLogin.idToken)
                        .update({
                      "Food": FieldValue.arrayUnion([foodInfo])
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
                      ),
                      SizedBox(height: 40),
                      Text(
                          'Would you like to add this item to an existing recipe?',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center),
                      SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () {
                            print("Pressed yes, adding to recipe");
                            _addtoRecipe(context);
                          },
                          child: Text('Yes')),
                      ElevatedButton(onPressed: null, child: Text('No')),
                    ]);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  print('item not scanned');
                  // By default, show a loading spinner.
                  return const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.greenAccent));
                },
              ),
            ),
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

    setState(() {
      this.scanResult = scanResult;
    });
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

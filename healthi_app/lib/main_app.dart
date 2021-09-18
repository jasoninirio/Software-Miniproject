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
  // ListWheelScrollView _controller = ListWheelScrollView(itemExtent: 100, );

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
        leading: Image.asset("assets/leaf.png"),
        backgroundColor: Colors.greenAccent[700],
        actions: [Image.asset("assets/plate.png")],
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

                      return ListWheelScrollView.useDelegate(
                          itemExtent: 125,
                          diameterRatio: 5.5,
                          perspective: 0.003,
                          physics: BouncingScrollPhysics(),
                          childDelegate: ListWheelChildBuilderDelegate(
                              childCount:
                                  foodItems != null ? foodItems.length : 0,
                              builder: (context, index) {
                                return Container(
                                  height: 75,
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.lightGreen[100],
                                    gradient: new LinearGradient(colors: [
                                      Colors.lightGreen.shade100,
                                      Colors.lightGreen.shade200,
                                      Colors.lightGreen.shade200,
                                      Colors.lightGreen.shade100,
                                    ]),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${foodItems[index]['Name']} - ${foodItems[index]['Calories']} KCal.",
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              }));

                      // return ListView.builder(
                      //   shrinkWrap: true,
                      //   physics: BouncingScrollPhysics(),
                      //   padding: const EdgeInsets.all(8),
                      //   itemCount: foodItems != null ? foodItems.length : 0,
                      //   itemBuilder: (_, int index) {
                      //     return Container(
                      //       height: 75,
                      //       margin: EdgeInsets.all(2),
                      //       decoration: BoxDecoration(
                      //         color: Colors.lightGreen[100],
                      //         borderRadius:
                      //             BorderRadius.all(Radius.circular(10)),
                      //       ),
                      //       child: Center(
                      //         child: Text(
                      //           "${foodItems[index]['Name']} - ${foodItems[index]['Calories']} KCal.",
                      //           style: TextStyle(fontSize: 16),
                      //           textAlign: TextAlign.center,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // );
                    } else {
                      return Container();
                    }
                  }),
            ),
            SizedBox(height: 15),
            FloatingActionButton.extended(
              onPressed: () {
                firestoreInstance
                    .collection('History')
                    .doc(UserLogin.idToken)
                    .update({
                  "Food": [],
                });
              },
              label: Text("Clear History"),
              icon: const Icon(Icons.clear),
              backgroundColor: Colors.green,
            ),
            SizedBox(height: 20),
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
                      "recipe": FieldValue.arrayUnion([recipeInfo]),
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
        leading: Image.asset("assets/recipe.png"),
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

                          return Dismissible(
                            direction: DismissDirection.endToStart,
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              setState(() {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            "${items[index]['Name']} deleted")));
                              });

                              firestoreInstance
                                  .collection('Recipes')
                                  .doc(UserLogin.idToken)
                                  .update({
                                "recipe": FieldValue.arrayRemove(
                                  [items[index]],
                                ),
                              });
                              items.removeAt(index);
                            },
                            background: Container(
                              color: Colors.red,
                            ),
                            child: ExpansionTile(
                              title: Text("${items[index]['Name']}"),
                              subtitle: Text(
                                  "${items[index]['Calories'].toString()} KCal"),
                              children: children,
                            ),
                          );
                        },
                      );
                    } else {
                      return Container(
                        child: Text(
                          "Add Some Recipes!",
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          _displayTextInputDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// Camera page - has barcode scanner that calls FDC API
class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  Stream<DocumentSnapshot> rdata = firestoreInstance
      .collection('Recipes')
      .doc(UserLogin.idToken)
      .snapshots();
  String? scanResult;
  String selectedRecipe = "";
  late Future<FoodInfo> futureFoodInfo;

  Future _addtoRecipe(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Select Recipe',
                textAlign: TextAlign.center,
              ),
              centerTitle: true,
              backgroundColor: Colors.greenAccent[700],
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: StreamBuilder(
                        stream: rdata,
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            var recipes = snapshot.data!;
                            var items = recipes['recipe'];
                            var db_data = items;

                            return ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(8),
                              itemCount: items != null ? items.length : 0,
                              itemBuilder: (_, int index) {
                                return ListTile(
                                  title: Text("${items[index]['Name']}"),
                                  subtitle: Text(
                                      "${items[index]['Calories'].toString()} KCal"),
                                  enabled: true,
                                  onTap: () {
                                    var scannedObj = snapshot.data!['recipe']
                                        [index]['Ingredients'];

                                    setState(() {
                                      selectedRecipe = snapshot.data!['recipe']
                                          [index]['Name'];

                                      var updatedCal = snapshot.data!['recipe']
                                              [index]['Calories'] +
                                          FoodInfoVar.food_calories;

                                      scannedObj.add(
                                          '${FoodInfoVar.food_desc} - ${FoodInfoVar.food_calories} KCal.');

                                      print(scannedObj);

                                      var ingredientInfo =
                                          new Map<String, dynamic>();
                                      ingredientInfo = {
                                        "Name": selectedRecipe,
                                        "Ingredients": scannedObj,
                                        "Calories": updatedCal
                                      };

                                      db_data[index] = ingredientInfo;
                                    });

                                    firestoreInstance
                                        .collection("Recipes")
                                        .doc(UserLogin.idToken)
                                        .set(
                                          ({
                                            "recipe":
                                                FieldValue.arrayUnion(db_data),
                                          }),
                                        );

                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "${FoodInfoVar.food_desc} added to $selectedRecipe")));
                                  },
                                );
                              },
                            );
                          } else {
                            return Container();
                          }
                        }),
                  ),
                ],
              ),
            ),
            floatingActionButton: new FloatingActionButton.extended(
              label: Text("Add New Recipe"),
              onPressed: () {
                _ProfilePageState()._displayTextInputDialog(context);
              },
              icon: Icon(Icons.add),
              backgroundColor: Colors.green,
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Scan a Food Item!'),
          centerTitle: true,
          leading: Image.asset("assets/barcode.png"),
          backgroundColor: Colors.greenAccent[700]),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton.extended(
              label: Text(scanResult == null ? 'SCAN' : 'SCAN AGAIN'),
              icon: const Icon(Icons.camera),
              backgroundColor: Colors.green,
              onPressed: scanBarcode,
            ),
            SizedBox(height: 80),
            Center(
              child: FutureBuilder<FoodInfo>(
                future: futureFoodInfo = fetchFoodInfo(scanResult.toString()),
                builder: (context, snapshot) {
                  if (snapshot.hasData && scanResult != null) {
                    FoodInfoVar.food_calories = snapshot.data!.calories;
                    FoodInfoVar.food_desc =
                        snapshot.data!.description.toLowerCase();

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
                        'Food: ' +
                            (snapshot.data!.description.toLowerCase())
                                .toString(),
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
                      FloatingActionButton.extended(
                          onPressed: () => _addtoRecipe(context),
                          label: Text('Add to Recipe'),
                          icon: Icon(Icons.add),
                          backgroundColor: Colors.green),
                      SizedBox(height: 20),
                    ]);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

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

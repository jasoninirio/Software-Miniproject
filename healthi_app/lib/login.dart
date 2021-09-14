//SignInScreen

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthi_app/main_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Connecting to Cloud Firestore
final firestoreInstance = FirebaseFirestore.instance;

// User Credentials for App
class userLogin {
  static String firstName = '';
  static String lastName = '';
  static String idToken = '';
}

class LoginScreen extends StatefulWidget {
// LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.greenAccent[400],
        ),
        child: Card(
          margin: EdgeInsets.only(top: 200, bottom: 200, left: 30, right: 30),
          elevation: 20,
          color: Colors.greenAccent[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(image: AssetImage('assets/logo_full.png')),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: MaterialButton(
                    color: Colors.white,
                    elevation: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: 30.0,
                          width: 30.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/google.jpg'),
                                fit: BoxFit.cover),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("Sign In with Google")
                      ],
                    ),

                    // by onpressed we call the function signup function
                    onPressed: () {
                      signup(context);
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }

  static Map<String, dynamic> parseJwt(String token) {
    // validate token
    final List<String> parts = token.split('.');

    // retrieve token payload
    final String payload = parts[1];
    final String normalized = base64Url.normalize(payload);
    final String resp = utf8.decode(base64Url.decode(normalized));
    // convert to Map
    final payloadMap = json.decode(resp);
    return payloadMap;
  }

  // creating firebase instance
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> signup(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final idToken = googleSignInAuthentication.idToken;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Saving user credentials to collection
      UserCredential result = await auth.signInWithCredential(authCredential);
      User? user = result.user;

      // Get Credentials from login
      Map<String, dynamic> idMap = parseJwt(idToken!);

      userLogin.firstName = idMap["given_name"];
      userLogin.lastName = idMap["family_name"];
      userLogin.idToken = idToken;

      // Add to Cloud FireStore
      if (result != null) {
        firestoreInstance.collection('Users').doc(user!.uid).set({
          "Name": "${userLogin.firstName} ${userLogin.lastName}",
          "Recipes": [],
        }).then((_) {
          print("Success!");
        });

        // Get Credentials from login
        Map<String, dynamic> idMap = parseJwt(idToken!);

        userLogin.firstName = idMap["given_name"];
        userLogin.lastName = idMap["family_name"];
        userLogin.idToken = idToken;

        // Init app
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => App_PageView()));
      } // if result not null we simply call the MaterialpageRoute,
      // for go to the main app screen
    }
  }
}

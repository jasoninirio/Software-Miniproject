//SignInScreen

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:healthi_app/main_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splash_screen_view/SplashScreenView.dart';

// Connecting to Cloud Firestore
final firestoreInstance = FirebaseFirestore.instance;

// User Credentials for App
class UserLogin {
  static String firstName = '';
  static String lastName = '';
  static String idToken = '';
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: LoginScreen(),
      duration: 3000,
      imageSize: 130,
      imageSrc: "assets/logo_full.png",
      backgroundColor: Colors.white,
    );
  }
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
          color: Colors.greenAccent[100],
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

      // Add to Cloud FireStore - Check for existing users
      print("Signing in");
      if (result != null && user!.uid != null) {
        // Get Credentials from login
        Map<String, dynamic> idMap = parseJwt(idToken!);

        UserLogin.firstName = idMap["given_name"];
        UserLogin.lastName = idMap["family_name"];
        // UserLogin.idToken = idToken;
        UserLogin.idToken = user.uid;

        var checkRef = firestoreInstance.collection('Users').doc(user.uid);
        var doc = await checkRef.get();

        if (!doc.exists) {
          print("creating new user");
          firestoreInstance.collection('Users').doc(user.uid).set({
            "Name": "${UserLogin.firstName} ${UserLogin.lastName}",
          }).then((_) {
            print("Added to Users");
          });

          firestoreInstance.collection('Recipes').doc(user.uid).set({
            'recipe': [],
          }).then((_) {
            print("Added to Recipes");
          });

          firestoreInstance.collection('History').doc(user.uid).set({
            'Food': [],
          }).then((_) {
            print("Added to History");
          });
        }
        print('logging user in');
        print('USERLOGIN IDTOKEN: ${UserLogin.idToken}');

        // Init app
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => App_PageView()));
      } // if result not null we simply call the MaterialpageRoute,
      // for go to the main app screen
    }
  }
}

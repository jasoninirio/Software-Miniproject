// import 'dart:js';
// --no-sound-null-safety
import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore Database
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In
import "package:http/http.dart" as http;

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   scopes: [
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );

void main() {
  Firebase.initializeApp();
  runApp(MaterialApp(
    title: "Healthi App",
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
        backgroundColor: Colors.green,
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

// Camera Page - hosts the camera and a search bar to add food items to User's food tracker
class CameraPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('camera'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // Back Button
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: Text('Go Back')),
          ],
        ),
      ),
    );
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
                  Navigator.pushNamed(context, '/home');
                },
                child: Text('Go Back')),
          ],
        ),
      ),
    );
  }
}

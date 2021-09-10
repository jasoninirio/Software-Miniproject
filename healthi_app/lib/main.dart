import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthi_app/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init firebase
  await Firebase.initializeApp();

  // init app
  runApp(SignIn());
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

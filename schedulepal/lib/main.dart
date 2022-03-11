import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'signInScreen.dart';

/// App's entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initializing the firebase app
  await Firebase.initializeApp();

  // calling of runApp
  runApp(const GoogleSignIn());
}

class GoogleSignIn extends StatefulWidget {
  const GoogleSignIn({Key? key}) : super(key: key);
  @override
  _GoogleSignInState createState() => _GoogleSignInState();
}

class _GoogleSignInState extends State<GoogleSignIn> {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Really Simple To Do',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Sets the landing page of the app to be the sign in screen
      home: const SignInScreen(),
    );
  }
}
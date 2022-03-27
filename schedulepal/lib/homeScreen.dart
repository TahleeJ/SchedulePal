import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'signInScreen.dart';
import 'addCourseScreen.dart';
import 'friendsListScreen.dart';

/// Stateful class controlling the sign in page
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Builder for the homepage screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.greenAccent,
              Colors.yellow,
            ],
          ),
        ),
        // Card containing app name and sign in button
        child: Card(
          margin: const EdgeInsets.only(top: 200, bottom: 200, left: 30, right: 30),
          elevation: 20,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Schedule Pal!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                  onPressed: () {_signOut();},
                  child: Text(
                      "Sign out",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal)
                  )
              ),
              ElevatedButton(
                  onPressed: () {goAddCourse();},
                  child: Text(
                     "Add Course",
                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal)
                  )
              ),
              ElevatedButton(
                  onPressed: () {openFriendsList();},
                  child: Text(
                      "Friends List",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal)
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Signs out the currently signed in user and navigates to the sign in screen
  Future<void> _signOut() async {
      await auth.signOut();
      final GoogleSignIn googleSignIn = GoogleSignIn();
      googleSignIn.disconnect();
      goSignIn();
  }

  /// Navigates to the home page screen
  void goSignIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  /// Navigates to the add course screen
  void goAddCourse() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AddCourseScreen()));
  }

  void openFriendsList() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FriendsListScreen()));
  }
}

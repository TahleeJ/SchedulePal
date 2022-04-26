import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'friendsListScreen.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';

/// Stateful class controlling the sign in page
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

// Future<List<Map<String, dynamic>>>? _customEventsList = null;
// Future<List<Map<String, dynamic>>>? _coursesList = null;
// Future<Map<DateTimeRange, dynamic>>? _customEventsMap = null;
Future<Map<String, List<dynamic>>>? _eventsList = null;

class _EventsListScreenState extends State<EventsListScreen> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Builder for the homepage screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.pink[300],
          centerTitle: true,
          title: const Text("Schedule Pal"),
          leading: IconButton(onPressed: () => {openFriendsList()},
              icon: Icon(Icons.arrow_back)),
          actions: <Widget>[
            IconButton(onPressed: () => {goHome()},
                icon: Icon(Icons.home_rounded, size: 26.0),
                tooltip: "Home"),
            IconButton(onPressed: () => {openFriendsList()},
                icon: Icon(Icons.people_alt_outlined, size: 26.0),
                tooltip: "Friends List"),
            IconButton(onPressed: () => {_signOut()},
                icon: Icon(Icons.exit_to_app_outlined, size: 26.0,),
                tooltip: "Sign Out")

          ],
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.white
            ),
            child: Card(
              margin: const EdgeInsets.only(
                  top: 50, bottom: 50, left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                      children: <Widget>[
                        SizedBox(width: 15),
                        Text(
                          "My Events",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ]
                  ),
                ],
              ),
            )
        )
    );
  }

  // Future<List<Map<String, dynamic>>> _fetchCourses() async {
  //   var userRef = store.collection('User').doc(auth.currentUser?.uid);
  //   var userSnapshot = await userRef.get();
  //   var userCollection = store.collection("User");
  //
  //   Map<String, dynamic> friends;
  //
  //   // List to structurally hold all of a user's tasks in maps:
  //   // {name: task's name},
  //   // {latitude: task location's latitude},
  //   // {longitude: task location's longitude}
  //   List<Map<String, dynamic>> friendsList = [];
  //
  //   if (userSnapshot.exists) {
  //     friends = userSnapshot.data()!["friends"];
  //     friends.forEach((key, mapValue) async {
  //       if (mapValue == 0) {
  //         friendsList.add(Map.fromIterables(["uid", "name"], [key, (await userCollection.doc(key).get()).data()?["name"]]));
  //       }
  //     });
  //   }
  //
  //   await Future.delayed(Duration(milliseconds: 2000));
  // }

  // Future<List<Map<String, dynamic>>> _fetchCustomEvents() async {
  //   var userRef = store.collection('User').doc(auth.currentUser?.uid);
  //   var userSnapshot = await userRef.get();
  //   var userCollection = store.collection("User");
  //
  //   // Map<String, dynamic> friends;
  //   //
  //   // // List to structurally hold all of a user's tasks in maps:
  //   // // {name: task's name},
  //   // // {latitude: task location's latitude},
  //   // // {longitude: task location's longitude}
  //   // List<Map<String, dynamic>> friendsList = [];
  //   //
  //   // if (userSnapshot.exists) {
  //   //   friends = userSnapshot.data()!["friends"];
  //   //   friends.forEach((key, mapValue) async {
  //   //     if (mapValue == 0) {
  //   //       friendsList.add(Map.fromIterables(["uid", "name"], [key, (await userCollection.doc(key).get()).data()?["name"]]));
  //   //     }
  //   //   });
  //   // }
  //
  //   if (userSnapshot.exists) {
  //     List<String> customEvents = userSnapshot.data()!["events"];
  //
  //     customEvents.forEach((element) {
  //
  //     })
  //   }
  //
  //   await Future.delayed(Duration(milliseconds: 2000));
  // }

  /// Navigates back to the home screen
  void goHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  /// Signs out the currently signed in user and navigates to the sign in screen
  Future<void> _signOut() async {
    await auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    goSignIn();
  }

  /// Navigates to the sign in screen
  void goSignIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));
  }

  void openFriendsList() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FriendsListScreen()));
  }
}
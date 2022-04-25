import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'signInScreen.dart';
import 'addCourseScreen.dart';
import 'addEventScreen.dart';
import 'friendsListScreen.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
DateTime get _now => DateTime.now();
/// Stateful class controlling the sign in page
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<FlutterWeekViewEvent> events = [];
  /// Builder for the homepage screen
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        centerTitle: true,
        title: const Text("Schedule Pal"),
        actions: <Widget>[
          // Sign out button
          IconButton(onPressed: () => {openFriendsList()}, icon: Icon(Icons.people_alt_outlined, size: 26.0), tooltip: "Friend List"),
          IconButton(onPressed: () => {}, icon: Icon(Icons.event_rounded, size: 26.0), tooltip: "Events List"),
          IconButton(onPressed: () => {_signOut()}, icon: Icon(Icons.exit_to_app_outlined, size: 26.0, ),

            tooltip: "Sign Out",),
          IconButton(
            onPressed: () {
              setState(() {
                DateTime start = DateTime(now.year, now.month, now.day, Random().nextInt(24), Random().nextInt(60));
                events.add(FlutterWeekViewEvent(
                  title: 'Event ' + (events.length + 1).toString(),
                  start: start,
                  end: start.add(const Duration(hours: 1)),
                  description: 'A description.',
                ));
              });
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),

        ],
      ),
      body: WeekView(
          initialTime: const HourMinute(hour: 7).atDate(DateTime.now()),
          dates: [date.subtract(const Duration(days: 1)), date, date.add(const Duration(days: 1))],
          events: events
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAlertDialog(context),
        //onPressed: () => _addObject(context),
        tooltip: 'Add random task',
        child: Icon(Icons.add),
      ),

    );
  }

  showAlertDialog(BuildContext context) {

    // set up the buttons
    Widget eventButton = TextButton(
      child: Text("Custom Event"),
      onPressed:  () {goCreateEventPage();},
    );
    Widget courseButton = TextButton(
      child: Text("Course"),
      onPressed:  () {goAddCourse();},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Add to Calendar"),
      content: Text("Please click on the event type you would like to add."),
      actions: [
        eventButton,
        courseButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
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

  void goCreateEventPage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AddEventScreen()));
  }

  void openFriendsList() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FriendsListScreen()));
  }
}

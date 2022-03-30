import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'signInScreen.dart';
import 'addCourseScreen.dart';
import 'addEventScreen.dart';
import 'friendsListScreen.dart';
import 'package:time_planner/time_planner.dart';

DateTime get _now => DateTime.now();
/// Stateful class controlling the sign in page
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<TimePlannerTask> tasks = [];

  void _addObject(BuildContext context) {
    List<Color?> colors = [
      Colors.purple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.lime[600]
    ];

    setState(() {
      tasks.add(
        TimePlannerTask(
          color: colors[Random().nextInt(colors.length)],
          dateTime: TimePlannerDateTime(
              day: Random().nextInt(14),
              hour: Random().nextInt(18) + 6,
              minutes: Random().nextInt(60)),
          minutesDuration: Random().nextInt(90) + 30,
          daysDuration: Random().nextInt(4) + 1,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You click on time planner object')));
          },
          child: Text(
            'this is a demo',
            style: TextStyle(color: Colors.grey[350], fontSize: 12),
          ),
        ),
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Random task added to time planner!')));
  }

  /// Builder for the homepage screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        centerTitle: true,
        title: const Text("Schedule Pal"),
        actions: <Widget>[
          // Sign out button
          IconButton(onPressed: () => {openFriendsList()}, icon: Icon(Icons.accessibility, size: 26.0), tooltip: "Friend List"),
          IconButton(onPressed: () => {}, icon: Icon(Icons.event_rounded, size: 26.0), tooltip: "Events List"),
          IconButton(onPressed: () => {_signOut()}, icon: Icon(Icons.exit_to_app_outlined, size: 26.0, ),

            tooltip: "Sign Out",)

        ],
      ),
      body: Center(
        child: TimePlanner(
          // time will be start at this hour on table
          startHour: 6,
          // time will be end at this hour on table
          endHour: 23,
          // each header is a column and a day
          headers: [
            TimePlannerTitle(
              //date: "3/10/2021",
              title: "sunday",
            ),
            TimePlannerTitle(
              //date: "3/11/2021",
              title: "monday",
            ),
            TimePlannerTitle(
              ////date: "3/12/2021",
              title: "tuesday",
            ),
            TimePlannerTitle(
              //date: "3/12/2021",
              title: "wednesday",
            ),
            TimePlannerTitle(
              //date: "3/12/2021",
              title: "thursday",
            ),
            TimePlannerTitle(
              //date: "3/12/2021",
              title: "friday",
            ),
            TimePlannerTitle(
              //date: "3/12/2021",
              title: "saturday",
            )
          ],
          // List of task will be show on the time planner
          tasks: tasks,
          style: TimePlannerStyle(
            // cellHeight: 60,
            // cellWidth: 60,
            showScrollBar: true,
          ),
        ),
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

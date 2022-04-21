import 'dart:developer';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'signInScreen.dart';
import 'addCourseScreen.dart';
import 'addEventScreen.dart';
import 'friendsListScreen.dart';
import 'package:flutter_week_view/flutter_week_view.dart';

/// Stateful class controlling the sign in page
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;

  late Map<String, DateTime> weekDaysToDateTime = getDates();
  late List<DateTime> dates = weekDaysToDateTime.values.toList();
  late Future<List<FlutterWeekViewEvent>> events = getEvents(weekDaysToDateTime);

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
          IconButton(onPressed: () => {openFriendsList()}, icon: Icon(Icons.accessibility, size: 26.0), tooltip: "Friend List"),
          IconButton(onPressed: () => {}, icon: Icon(Icons.event_rounded, size: 26.0), tooltip: "Events List"),
          IconButton(onPressed: () => {_signOut()}, icon: Icon(Icons.exit_to_app_outlined, size: 26.0, ),
            tooltip: "Sign Out",),
        ],
      ),
      body: FutureBuilder<List<FlutterWeekViewEvent>>(
        future: events,
        builder: (context, snapshot) {
          return WeekView(
              initialTime: const HourMinute(hour: 7).atDate(DateTime.now()), //DateTime.now().subtract(const Duration(hours: 1)),
              dates: dates,
              events: snapshot.data,
              style: WeekViewStyle(dayViewWidth: 250),
              dayViewStyleBuilder: (DateTime date) {
                return DayViewStyle(hourRowHeight: 110);
              },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAlertDialog(context),
        //onPressed: () => _addObject(context),
        tooltip: 'Add random task',
        child: Icon(Icons.add),
      ),

    );
  }
  /// Get range of DateTimes from SUN -> SAT
  Map<String, DateTime> getDates() {
    List<String> weekDays = ['U', 'M', 'T', 'W', 'R', 'F', 'S'];
    List<DateTime> dates = [];

    DateTime today = DateTime.now();
    DateTime startDate = today.subtract(Duration(days: today.weekday));
    DateTime endDate = today.add(Duration(days: DateTime.daysPerWeek - today.weekday - 1));
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }

    Map<String, DateTime> weekDayToDateTime = new Map();
    for (int i = 0; i < weekDays.length; i++) {
      weekDayToDateTime[weekDays[i]] = dates[i];
    }

    return weekDayToDateTime;
  }

  /// Convert User courses to Calender Event Objects
  Future<List<FlutterWeekViewEvent>> getEvents(weekDayToDateTime) async {
    List<FlutterWeekViewEvent> events = [];
    var userId = auth.currentUser!.uid;
    var userRef = store.collection("User").doc(userId);
    List<dynamic> courseList = ((await userRef.get()).data()!["courses"] == null) ? [] : (await userRef.get()).data()!["courses"];

    for (Map<String, dynamic> course in courseList) {

      // Parse class time (9:00 am - 2:00 pm) -> [09:00, 14:00]
      List<String> times = course['time'].split(' - ');
      for (int i = 0; i < times.length; i++) {
        if (times[i].length == 7) {
          times[i] = '0' + times[i];
        }
        times[i] = times[i].toUpperCase();
      }
      DateTime startTime = DateFormat("hh:mm a").parse(times[0]);
      DateTime endTime = DateFormat("hh:mm a").parse(times[1]);

      // Parse class days (MWF -> MM/DD/YYYY)
      for (String day in course['days'].split('')) {
        DateTime date = weekDayToDateTime[day];
        DateTime start = new DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
        DateTime end = new DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

        // Build Calendar Event Object
        events.add(FlutterWeekViewEvent(
          title: course['number'],
          description: course['title'] + '\n' + course['location'],
          start: start,
          end: end,
          )
        );
      }

    }
    return events;
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

///------------------------------------Navigation-------------------------------

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

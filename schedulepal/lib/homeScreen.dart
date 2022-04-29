import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_week_view/flutter_week_view.dart';
import 'ad_helper.dart';
import 'package:flutter/material.dart';
import 'signInScreen.dart';
import 'addCourseScreen.dart';
import 'addEventScreen.dart';
import 'friendsListScreen.dart';
import 'eventsListScreen.dart';

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

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }


  bool zoomDay = true;
  double dayZoom = 110;
  double weekZoom = 250;
  void changeZoom() {
    setState(() {
      if (dayZoom == 110) {
        dayZoom = 60;
        weekZoom = 100;
      }
      else if (dayZoom == 60) {
        dayZoom = 110;
        weekZoom = 250;
      }

      zoomDay = !zoomDay;
    });
  }

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
          IconButton(onPressed: () => {openEventsList()}, icon: Icon(Icons.event_rounded, size: 26.0), tooltip: "Events List"),
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
              style: WeekViewStyle(dayViewWidth: weekZoom),
              dayViewStyleBuilder: (DateTime date) {
                return DayViewStyle(hourRowHeight: dayZoom);
              },
          );
        }
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 75,
            child: FloatingActionButton(
              onPressed: () => showAlertDialog(context),
              //onPressed: () => _addObject(context),
              tooltip: 'Add Event',
              child: Icon(Icons.add),
              heroTag: 'Add'
            )
          ),
          Positioned(
            right: 0,
            bottom: 140,
            child: FloatingActionButton(
              onPressed: () => changeZoom(),
              //onPressed: () => _addObject(context),
              tooltip: zoomDay ? 'Week View' : 'Day View',
              child: Icon(zoomDay ? Icons.zoom_out_rounded : Icons.zoom_in_rounded),
              heroTag: 'Zoom'
            )
          ),
          if (_isBannerAdReady)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: _bannerAd.size.width.toDouble(),
                height: _bannerAd.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd),
              ),
            ),
        ]
      )
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
    List<dynamic> eventList = ((await userRef.get()).data()!["events"] == null) ? [] : (await userRef.get()).data()!["events"];

    for (String event in eventList) {
      var _eventRef = store.collection("Events").doc(event);
      var query = await _eventRef.get();
      var format = DateFormat("yyyy:MM:dd:HH:mm");
      var dTime = query.data()!['date'];
      var dt = format.format(dTime.toDate());
      List<String> date = dt.split(':');
      var sTime = query.data()!['startTime'];
      var st = format.format(sTime.toDate());
      List<String> start = st.split(':');
      var eTime = query.data()!['endTime'];
      var et = format.format(eTime.toDate());
      List<String> end = et.split(':');
      events.add(FlutterWeekViewEvent(
        title: query.data()!['name'],
        description: query.data()!['description'] + '\n' + query.data()!['location'],
        // start: new DateTime(int.parse(date[0]), int.parse(date[1]), 26, 10, 30),
        // end: new DateTime(2022, 4, 26, 11, 30),
        start: new DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]), int.parse(start[3]), int.parse(start[4])),
        end: new DateTime(int.parse(date[0]), int.parse(date[1]), int.parse(date[2]), int.parse(end[3]), int.parse(end[4])),
      )
      );
    }

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

  void openEventsList() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => EventsListScreen()));
  }
}

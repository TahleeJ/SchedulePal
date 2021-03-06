import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signInScreen.dart';
import 'friendsListScreen.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'homeScreen.dart';

/// Stateful class controlling the add course page
class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({Key? key}) : super(key: key);

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  // Project's Firebase authentication instance
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<List<Course>>? courses;
  String searchString = '';

  @override
  void initState() {
    super.initState();
    courses = fetchCourses(searchString);
  }

  /// Builder for the homepage screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.pink[300],
        centerTitle: true,
        title: const Text("Schedule Pal"),
        leading: IconButton(onPressed: () =>{goHome()}, icon: Icon(Icons.arrow_back),),
        actions: <Widget>[
          IconButton(onPressed: () => {goHome()}, icon: Icon(Icons.home_rounded, size: 26.0), tooltip: "Home"),
          IconButton(onPressed: () => {openFriendsList()}, icon: Icon(Icons.people_alt_outlined, size: 26.0), tooltip: "Friends List"),
          IconButton(onPressed: () => {_signOut()}, icon: Icon(Icons.exit_to_app_outlined, size: 26.0), tooltip: "Sign Out")

        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white
        ),
        // Card containing page name and course search
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Card(
            margin: const EdgeInsets.only(top: 50, bottom: 50, left: 20, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: <Widget>[
                    SizedBox(width: 15),
                    Text(
                      "Course Search",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ]
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchString = value.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                            labelText: 'Search (e.g., \'CS 1332\')', suffixIcon: Icon(Icons.search)),
                      ),
                    ),
                    FutureBuilder(
                      builder: (ctx, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                '${snapshot.error}',
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          } else if (snapshot.hasData) {
                            final courses = snapshot.data as List;
                            return ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemCount: courses.length,
                              itemBuilder: (ctx, index) {
                                Course course = courses[index];
                                return CourseWidget(course, auth, store);
                              },
                            );
                          }
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      future: fetchCourses(searchString),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      )
    );
  }

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

/// Course Card Custom Widget
class CourseWidget extends StatelessWidget {
  CourseWidget(this.course, this.auth, this.store);

  final Course course;
  final FirebaseFirestore store;
  final FirebaseAuth auth;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Column(
                    children: <Widget>[
                      Text(course.number, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      Text(course.title, style: TextStyle(fontSize: 10), textAlign: TextAlign.center),
                    ]
                ),
              ),

              Expanded(
                flex: 5,
                child: Column(
                    children: <Widget>[
                      Text(course.instructors, style: TextStyle(fontSize: 8), overflow: TextOverflow.ellipsis),
                      Text(course.location, style: TextStyle(fontSize: 8)),
                      Text(course.time, style: TextStyle(fontSize: 8)),
                      Text(course.days, style: TextStyle(fontSize: 8)),
                    ]
                ),
              ),

              Expanded(
                flex: 2,
                child: Column(
                    children: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(5)
                        ),
                        child: const Icon(Icons.add, size: 20),
                        onPressed: () {
                          handleAddCourse();
                        },
                      ),
                    ]
                ),
              ),
            ]
        )
    );
  }

  Future<void> handleAddCourse() async {
    var userId = auth.currentUser!.uid;
    var userRef = store.collection("User").doc(userId);
    List<dynamic> courseList = ((await userRef.get()).data()!["courses"] == null) ? [] : (await userRef.get()).data()!["courses"];
    List<dynamic> courseCrnList = ((await userRef.get()).data()!["crn_list"] == null) ? [] : (await userRef.get()).data()!["crn_list"];
    courseList.add(course.json);
    courseCrnList.add(course.crn);
    await userRef.update({"courses": courseList});
    await userRef.update({"crn_list": courseCrnList});
  }
}

class Course {
  final crn;
  final date_range;
  final days;
  final score;
  final instructors;
  final location;
  final number;
  final schedule_type;
  final section;
  final time;
  final title;
  final type;
  final json;

  Course({
    required this.crn,
    required this.date_range,
    required this.days,
    required this.score,
    required this.instructors,
    required this.location,
    required this.number,
    required this.schedule_type,
    required this.section,
    required this.time,
    required this.title,
    required this.type,
    required this.json,
  });


  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      crn: json['crn'],
      date_range: json['date_range'],
      days: json['days'],
      score: json['score'],
      instructors: json['instructors'],
      location: json['location'],
      number: json['number'],
      schedule_type: json['schedule_type'],
      section: json['section'],
      time: json['time'],
      title: json['title'],
      type: json['type'],
      json: json,
    );
  }

}

Future<List<Course>> fetchCourses(String query) async {
  if (query.split(' ').length != 2) throw ('...');
  String subject = query.split(' ')[0];
  String number = query.split(' ')[1];
  final response = await http.get(Uri.parse('https://gtcoursesscraper.ferasalsaiari.repl.co/lookup?course_subject=$subject&course_number=$number'));

  if (response.statusCode == 200) {
    var topCoursesJson = jsonDecode(response.body)['courses'] as List;
    var courses = topCoursesJson.map((course) => Course.fromJson(course)).toList();
    return courses;
  } else {
    throw ('Course not found');
  }
}


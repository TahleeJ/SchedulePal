import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'friendsListScreen.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';
import 'eventsListScreen.dart';
import 'package:intl/intl.dart';

/// Stateful class controlling the sign in page
class SharedEventScreen extends StatefulWidget {
  final String eventId;
  const SharedEventScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _SharedEventScreenState createState() => _SharedEventScreenState();
}

// Future<List<Map<String, dynamic>>>? _customSharedEvent = null;
// Future<List<Map<String, dynamic>>>? _coursesList = null;
// Future<Map<DateTimeRange, dynamic>>? _customEventsMap = null;

Future<bool> _eventLoaded = false as Future<bool>;
Future<List<Map<String, dynamic>>>? _friendsList = null;

class _SharedEventScreenState extends State<SharedEventScreen> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  var _eventData;

  var _title;
  var _description;
  var _location;
  var _date;
  var _startTime;
  var _endTime;

  @override
  void initState() {
    super.initState();
    _friendsList = _getEvent();
  }

  /// Builder for the homepage screen
  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.pink[300],
          centerTitle: true,
          title: const Text("Schedule Pal"),
          leading: IconButton(onPressed: () => {openEventsList()},
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
                          "Shared Event",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Divider()
                      ]
                  ),
                  FutureBuilder(
                      future: _friendsList,
                      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return const CircularProgressIndicator();
                          case ConnectionState.done:
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        '${_title}\n${_date}\n${_startTime}-${_endTime}\n${_location}\n${_description}',
                                          style: TextStyle(fontSize: 20)
                                      ),
                                      Divider(),
                                      Text(
                                        'Shared Friends',
                                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                                      ),
                                      Container(
                                          height: 300,
                                          child: ListView.builder(
                                              padding: EdgeInsets.all(10.0),
                                              itemCount: snapshot.data!.length,
                                              itemBuilder: (BuildContext context, int index) {
                                                return _buildFriend(
                                                    snapshot.data![index]["uid"]!,
                                                    snapshot.data![index]["name"]!
                                                );
                                              }
                                          )
                                      )
                                  ]
                                ),
                              ],
                            );
                          default:
                            return Text(
                              "This event could not be found!",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            );
                        }
                      }
                  )
                ],
              ),
            )
        )
    );
  }

  Widget _buildFriend(String uid, String name) {
    bool _isRemoved = false;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          StatefulBuilder(builder: (context, _setState) =>
              Container(
                  decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      border: Border.all(color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(right: 20.0, left: 20.0, top: 10.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(right: 15.0),
                              child: CircleAvatar(
                                  child: Icon(Icons.person, size: 15, color: Colors.grey),
                                  backgroundColor: Colors.white
                              )
                          ),
                          Padding(
                              padding: EdgeInsets.only(right: 15.0),
                              child: Text(name, style: TextStyle(fontSize: 20, color: Colors.white))
                          ),
                          Spacer(),
                          GestureDetector(
                              onTap: () {
                                //*****TODO: CALENDAR
                                _setState(() {});
                              },
                              child: Icon(Icons.calendar_today_rounded, size: 30, color: Colors.white)
                          )
                        ],
                      )
                  )
              )
          ),
          const Divider(
              height: 10.0,
              thickness: 1.0,
              color: Colors.white,
              indent: 20.0,
              endIndent: 20.0
          )
        ]
    );
  }

  Future<List<Map<String, dynamic>>> _getEvent() async {
    var eventRef = store.collection('Events').doc(widget.eventId);
    var eventData = (await eventRef.get()).data();

    _title = eventData?['name'];
    _description = eventData?['description'];
    _location = eventData?['location'];
    _date = DateFormat('MM/dd/yyyy').format(eventData?['date'].toDate());
    _startTime = DateFormat('hh:mm a').format(eventData?['endTime'].toDate());;
    _endTime = DateFormat('hh:mm a').format(eventData?['startTime'].toDate());;

    // _friendsList = await getSharedFriends();

    return getSharedFriends();
  }

  Future<List<Map<String, dynamic>>> getSharedFriends() async {
    print("enter");
    var userCollection = store.collection('User');
    var userSnapshot = await userCollection.doc('KsHbpcV4qfQzGJlgkJU1qmVjJ1s1').get();
    List<String> friendData;

    Map<String, dynamic> friends;

    // List to structurally hold all of a user's tasks in maps:
    // {name: task's name},
    // {latitude: task location's latitude},
    // {longitude: task location's longitude}
    List<Map<String, dynamic>> friendsList = [];

    if (userSnapshot.exists) {
      print("another");
      friends = userSnapshot.data()!["friends"];
      print(friends);

      await Future.forEach(friends.entries, (element) async {
        // Map<String, dynamic> friendEntry = Map.fromEntries([]);
        MapEntry<String, dynamic> friendEntry = element as MapEntry<String, dynamic>;

        if (friendEntry.value == 0) {

          friendData = (await userCollection.doc(friendEntry.key).get()).data()!['events'];

          if (friendData.contains(widget.eventId)) {
            friendsList.add(Map.fromIterables(["uid", "name"], [friendEntry.key, (await userCollection.doc(friendEntry.key).get()).data()?["name"]]));
          }
        }
      });
    }

    await Future.delayed(Duration(milliseconds: 2000));

    return friendsList;
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

  void openEventsList() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => EventsListScreen()));
  }
}
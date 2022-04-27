import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'friendsListScreen.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';
import 'package:intl/intl.dart';
import 'eventEditorScreen.dart';

/// Stateful class controlling the sign in page
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

// Future<List<Map<String, dynamic>>>? _customEventsList = null;
// Future<List<Map<String, dynamic>>>? _coursesList = null;
// Future<Map<DateTimeRange, dynamic>>? _customEventsMap = null;
Future<Map<String, List<Map<String, dynamic>>>?> _eventsListFuture = {} as Future<Map<String, List<Map<String, dynamic>>>?>;

class _EventsListScreenState extends State<EventsListScreen> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, List<Map<String, dynamic>>>? _eventsList = {};

  List<Color> cardColors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.deepPurpleAccent];

  @override
  void initState() {
    super.initState();
    _eventsListFuture = _fetchCustomEvents();
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
                  FutureBuilder(
                      future: _eventsListFuture,
                      builder: (context, AsyncSnapshot<Map<String, List<Map<String, dynamic>>>?> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return const CircularProgressIndicator();
                          case ConnectionState.done:
                            if (snapshot.hasData) {
                              Map<String, List<Map<String, dynamic>>?> eventsMap = Map.from(snapshot.data as Map<String, List<Map<String, dynamic>>?>);
                              var eventDates = eventsMap.keys.toList();

                              return Container(
                                height: MediaQuery.of(context).size.height - 200,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(10.0),
                                  itemCount: eventsMap.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(eventDates[index], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline, color: Colors.black)),
                                        ListView.builder(
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          itemCount: eventsMap[eventDates[index]]!.length,
                                          itemBuilder: (BuildContext eventContext, int eventIndex) {
                                            return _buildEvent(eventsMap[eventDates[index]]![eventIndex], cardColors[index % cardColors.length]);
                                          }
                                        )
                                      ],
                                    );
                                  }
                                ),
                              );
                            } else {
                              return Text(
                                  'No events',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                              );
                            }
                          default:
                            return Text(
                              'No events',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
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

  Widget _buildEvent(Map<String, dynamic> eventData, Color cardColor) {
    bool _isRemoved = false;

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget> [
          StatefulBuilder(builder: (context, _setState) =>
              Container(
                  decoration: BoxDecoration(
                      color: cardColor,
                      border: Border.all(color: cardColor),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(eventData['title'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: !_isRemoved ? TextDecoration.none : TextDecoration.underline, color: Colors.white)),
                                  Divider(),
                                  Text('${eventData['startTime']}-${eventData['endTime']}', style: TextStyle(fontSize: 12, decoration:! _isRemoved ? TextDecoration.none : TextDecoration.underline, color: Colors.white)),
                                  Text(eventData['location'], style: TextStyle(fontSize: 12, decoration: !_isRemoved ? TextDecoration.none : TextDecoration.underline, color: Colors.white))
                                ],
                              )
                          ),
                          Spacer(),
                          Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  _setState(() {
                                    _isRemoved = true;

                                    removeEvent(eventData['id']);
                                  });
                                },
                                child: Icon(Icons.highlight_remove_rounded)
                              ),
                              GestureDetector(
                                  onTap: () {
                                    _setState(() {
                                      goEditEvent(eventData['id']);
                                    });
                                  },
                                  child: Icon(Icons.create_rounded)
                              ),
                              GestureDetector(
                                  onTap: () {
                                    _setState(() {});
                                  },
                                  child: Icon(Icons.people_alt_outlined)
                              )
                            ],
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

  Future<Map<String, List<Map<String, dynamic>>>?> _fetchCustomEvents() async {
    // var userRef = store.collection('User').doc(auth.currentUser?.uid);
    var userRef = store.collection('User').doc('KsHbpcV4qfQzGJlgkJU1qmVjJ1s1');
    var userSnapshot = await userRef.get();
    var eventCollection = store.collection("Events");

    if (userSnapshot.exists) {
      List<dynamic> customEvents = userSnapshot.data()!["events"];

      await Future.forEach(customEvents, (element) async {
        var event = (await eventCollection.doc(element.toString()).get()).data();
        Map<String, dynamic> eventData = {};
        final date = DateFormat('MM/dd/yyyy').format(event?['date'].toDate());

        eventData['id'] = element.toString();
        eventData['date'] = date;
        eventData['startTime'] = DateFormat('hh:mm a').format(event?['startTime'].toDate());
        eventData['endTime'] = DateFormat('hh:mm a').format(event?['endTime'].toDate());
        eventData['title'] = event?['name'];
        eventData['description'] = event?['description'];
        eventData['location'] = event?['location'];

        if (_eventsList!.containsKey(date)) {
          _eventsList![date]!.add(eventData);
        } else {
          _eventsList![date] = [eventData];
        }
      });
    }

    await Future.delayed(Duration(milliseconds: 2000));

    return _eventsList;
  }

  Future<void> removeEvent(String id) async {
    // var userRef = store.collection('User').doc(auth.currentUser?.uid);
    var userRef = store.collection('User').doc('KsHbpcV4qfQzGJlgkJU1qmVjJ1s1');

    await userRef.update(
      { 'events': FieldValue.arrayRemove([id]) }
    );

    _eventsListFuture = _fetchCustomEvents();
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

  void goEditEvent(String eventId) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => EventEditorScreen(eventId: eventId)));
  }
}
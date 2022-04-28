import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:really_simple_chat/eventEditorScreen.dart';
import 'package:really_simple_chat/invitedEventsScreen.dart';
import 'friendsListScreen.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';
import 'package:intl/intl.dart';
import 'eventEditorScreen.dart';
import 'invitedEventsScreen.dart';
import 'sharedEventScreen.dart';

/// Stateful class controlling the sign in page
class EventsListScreen extends StatefulWidget {
  const EventsListScreen({Key? key}) : super(key: key);

  @override
  _EventsListScreenState createState() => _EventsListScreenState();
}

Future<Map<String, List<Map<String, dynamic>>>?> _eventsListFuture = {} as Future<Map<String, List<Map<String, dynamic>>>?>;

class _EventsListScreenState extends State<EventsListScreen> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  Map<String, List<Map<String, dynamic>>>? _eventsList = {};

  List<Color> cardColors = [Colors.blue, Colors.green, Colors.orange, Colors.red, Colors.deepPurpleAccent];
  List<String> removedCourses = [];

  // late Map<String, DateTime> weekDaysToDateTime = getDates();
  // late List<DateTime> dates = weekDaysToDateTime.values.toList();

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
          leading: IconButton(onPressed: () => {goHome()},
              icon: Icon(Icons.arrow_back)),
          actions: <Widget>[
            IconButton(onPressed: () => {goHome()},
                icon: Icon(Icons.home_rounded, size: 26.0),
                tooltip: "Home"),
            IconButton(onPressed: () =>{openEventInvites()},
                icon: Icon(Icons.hourglass_bottom_rounded, size: 30),
                tooltip: "Event Invites"),
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
                  top: 25, bottom: 50, left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(width: 15),
                        Text(
                          "My Events",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Divider()
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
                                height: MediaQuery.of(context).size.height - 175,
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
                                            return eventsMap[eventDates[index]]![eventIndex]['custom'] ?
                                              _buildEvent(eventsMap[eventDates[index]]![eventIndex], cardColors[index % cardColors.length]) :
                                              _buildCourse(eventsMap[eventDates[index]]![eventIndex], cardColors[index % cardColors.length]);
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
                                  Text(eventData['title'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: !_isRemoved ? TextDecoration.none : TextDecoration.lineThrough, color: Colors.white)),
                                  Divider(),
                                  Text('${eventData['startTime']}-${eventData['endTime']}', style: TextStyle(fontSize: 12, decoration:! _isRemoved ? TextDecoration.none : TextDecoration.lineThrough, color: Colors.white)),
                                  Text(eventData['location'], style: TextStyle(fontSize: 12, decoration: !_isRemoved ? TextDecoration.none : TextDecoration.lineThrough, color: Colors.white))
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
                                    _setState(() {
                                      goSeeSharedFriend(eventData['id'], true);
                                    });
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

  Widget _buildCourse(Map<String, dynamic> eventData, Color cardColor) {
    bool _isRemoved = removedCourses.contains(eventData['crn']);

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
                                  Text(eventData['title'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, decoration: !_isRemoved ? TextDecoration.none : TextDecoration.lineThrough, color: Colors.white)),
                                  Divider(),
                                  Text('${eventData['startTime']}-${eventData['endTime']}', style: TextStyle(fontSize: 12, decoration:! _isRemoved ? TextDecoration.none : TextDecoration.lineThrough, color: Colors.white)),
                                  Text(eventData['location'], style: TextStyle(fontSize: 12, decoration: !_isRemoved ? TextDecoration.none : TextDecoration.lineThrough, color: Colors.white))
                                ],
                              )
                          ),
                          Spacer(),
                          Column(
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () {
                                    _setState(() {
                                      removedCourses.add(eventData['crn']);

                                      removeCourse(eventData['crn']);
                                    });
                                  },
                                  child: Icon(Icons.highlight_remove_rounded)
                              ),
                              GestureDetector(
                                  onTap: () {
                                    _setState(() {
                                      goSeeSharedFriend(eventData['crn'], false);
                                    });
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

  /// Get range of DateTimes from SUN -> SAT
  List<DateTime> getDates(DateTime endDate, List<num> courseWeekdays) {
    List<String> weekDays = ['U', 'M', 'T', 'W', 'R', 'F', 'S'];
    List<DateTime> dates = [];

    DateTime today = DateTime.now();
    DateTime startDate = today;
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      DateTime newDate = startDate.add(Duration(days: i));

      if (courseWeekdays.contains(newDate.weekday)) {
        dates.add(newDate);
      }
    }

    // Map<String, DateTime> weekDayToDateTime = new Map();
    // for (int i = 0; i < weekDays.length; i++) {
    //   weekDayToDateTime[weekDays[i]] = dates[i];
    // }

    return dates;
  }

  int getDateMonth(String month) {
    int newMonth = 0;

    switch (month) {
      case 'Jan':
        newMonth = 1;
        break;
      case 'Feb':
        newMonth = 2;
        break;
      case 'Mar':
        newMonth = 3;
        break;
      case 'Apr':
        newMonth = 4;
        break;
      case 'May':
        newMonth = 5;
        break;
      case 'Jun':
        newMonth = 6;
        break;
      case 'Jul':
        newMonth = 7;
        break;
      case 'Aug':
        newMonth = 8;
        break;
      case 'Sep':
        newMonth = 9;
        break;
      case 'Oct':
        newMonth = 10;
        break;
      case 'Nov':
        newMonth = 11;
        break;
      case 'Dec':
        newMonth = 12;
        break;
    }

    return newMonth;
}

  Future<Map<String, List<Map<String, dynamic>>>?> _fetchCourses() async {
    // var userRef = store.collection('User').doc(auth.currentUser?.uid);
    var userRef = store.collection('User').doc('KsHbpcV4qfQzGJlgkJU1qmVjJ1s1');
    var userSnapshot = await userRef.get();

    if (userSnapshot.exists) {
      List<dynamic> courses = userSnapshot.data()!['courses'];

      for (Map<String, dynamic> course in courses) {
        // Parse class time (9:00 am - 2:00 pm) -> [09:00, 14:00]
        List<String> times = course['time'].split(' - ');
        for (int i = 0; i < times.length; i++) {
          if (times[i].length == 7) {
            times[i] = '0' + times[i];
          }
          times[i] = times[i].toUpperCase();
        }
        String startTime = DateFormat("hh:mm a").format(DateFormat("hh:mm a").parse(times[0]));
        String endTime = DateFormat("hh:mm a").format(DateFormat("hh:mm a").parse(times[1]));

        List<String> dateRange = course['date_range']!.split('-');
        dateRange[0] = dateRange[0].trim();
        dateRange[1] = dateRange[1].trim();

        List<int> dateRangeMonth = [];
        dateRangeMonth.add(getDateMonth(dateRange[0].substring(0, 3)));
        dateRangeMonth.add(getDateMonth(dateRange[1].substring(0, 3)));

        List<int> dateRangeDay = [];
        String tempDay;

        tempDay = dateRange[0].substring(4, 6);
        if (tempDay.substring(0, 1) == '0') {
          tempDay = tempDay.substring(1);
        }
        dateRangeDay.add(int.parse(tempDay));

        tempDay = dateRange[1].substring(4, 6);
        if (tempDay.substring(0, 1) == '0') {
          tempDay = tempDay.substring(1);
        }
        dateRangeDay.add(int.parse(tempDay));

        List<DateTime> dateRangeDateTime = [
          new DateTime(int.parse(dateRange[0].substring(8)), dateRangeMonth[0], dateRangeDay[0]),
          new DateTime(int.parse(dateRange[1].substring(8)), dateRangeMonth[1], dateRangeDay[1])
        ];

        List<num> courseWeekDays = [];

        for (String day in course['days'].split('')) {
          switch (day) {
            case 'M':
              courseWeekDays.add(1);
              break;
            case 'T':
              courseWeekDays.add(2);
              break;
            case 'W':
              courseWeekDays.add(3);
              break;
            case 'R':
              courseWeekDays.add(4);
              break;
            case 'F':
              courseWeekDays.add(5);
              break;
          }
        }

        List<DateTime> courseDates = getDates(dateRangeDateTime[1], courseWeekDays);

        for (DateTime dateTime in courseDates) {
          final date = DateFormat('MM/dd/yyyy').format(dateTime);
          Map<String, dynamic> eventData = {};

          eventData['custom'] = false;
          eventData['crn'] = course['crn'];
          eventData['date'] = date;
          eventData['startTime'] = startTime;
          eventData['endTime'] = endTime;
          eventData['number'] = '${course['number']} Section ${course['section']}';
          eventData['title'] = '${course['title']} - ${course['schedule_type']}';
          eventData['location'] = course['location'];

          if (_eventsList!.containsKey(date)) {
            _eventsList![date]!.add(eventData);
          } else {
            _eventsList![date] = [eventData];
          }
        }
      }
    }
}

  Future<Map<String, List<Map<String, dynamic>>>?> _fetchCustomEvents() async {
    var userRef = store.collection('User').doc(auth.currentUser?.uid);
    // var userRef = store.collection('User').doc('KsHbpcV4qfQzGJlgkJU1qmVjJ1s1');
    var userSnapshot = await userRef.get();
    var eventCollection = store.collection("Events");

    if (userSnapshot.exists) {
      List<dynamic> customEvents = userSnapshot.data()!["events"];

      await Future.forEach(customEvents, (element) async {
        var event = (await eventCollection.doc(element.toString().trim()).get()).data();
        Map<String, dynamic> eventData = {};
        final date = DateFormat('MM/dd/yyyy').format(event?['date'].toDate());

        eventData['custom'] = true;
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

    await _fetchCourses();

    await Future.delayed(Duration(milliseconds: 2000));

    return _eventsList;
  }

  Future<void> removeCourse(String crn) async {
    // var userRef = store.collection('User').doc(auth.currentUser?.uid);
    var userRef = store.collection('User').doc('KsHbpcV4qfQzGJlgkJU1qmVjJ1s1');
    var courseList = (await userRef.get()).data()!['courses'];

    for (Map<String, dynamic> course in courseList) {
      if (course['crn'] == crn) {
        userRef.update(
            { 'courses' : FieldValue.arrayRemove([course]) }
        );

        break;
      }
    }

    await userRef.update(
        { 'crn_list': FieldValue.arrayRemove([crn]) }
    );

    _eventsListFuture = _fetchCustomEvents();
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

  void openEventInvites() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => InvitedEventsScreen()));
  }

  void goSeeSharedFriend(String eventId, bool custom) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SharedEventScreen(eventId: eventId, custom: custom)));
  }
}
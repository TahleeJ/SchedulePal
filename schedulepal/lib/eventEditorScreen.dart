import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'friendsListScreen.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';
import 'eventsListScreen.dart';

/// Stateful class controlling the sign in page
class EventEditorScreen extends StatefulWidget {
  final String eventId;
  const EventEditorScreen({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventEditorScreenState createState() => _EventEditorScreenState();
}

// Future<List<Map<String, dynamic>>>? _customEventEditor = null;
// Future<List<Map<String, dynamic>>>? _coursesList = null;
// Future<Map<DateTimeRange, dynamic>>? _customEventsMap = null;

Future<bool> _eventLoaded = false as Future<bool>;

class _EventEditorScreenState extends State<EventEditorScreen> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  var _eventData;

  var _titleController = TextEditingController();
  var _descriptionController = TextEditingController();
  var _locationController = TextEditingController();
  var _date;
  var _startTime;
  var _endTime;

  @override
  void initState() {
    super.initState();
    _eventLoaded = _getEvent();
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
                          "Event Editor",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Divider()
                      ]
                  ),
                  FutureBuilder(
                      future: _eventLoaded,
                      builder: (context, snapshot) {
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
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                    child: Text(
                                        "Title",
                                        style: TextStyle(
                                            fontSize: 28),
                                      )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    child:
                                    TextField(
                                      controller: _titleController,
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                      child: Text(
                                        "Description",
                                        style: TextStyle(
                                            fontSize: 28),
                                      )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    child:
                                    TextField(
                                      controller: _descriptionController,
                                      maxLines: null
                                    ),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                      child: Text(
                                        "Location",
                                        style: TextStyle(
                                            fontSize: 28),
                                      )
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    child:
                                    TextField(
                                      controller: _locationController,
                                    ),
                                  )
                                  ]
                                ),
                                  Divider(),
                                  Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                          onPressed: () => showDateSelection(context),
                                          child: Text(
                                              'Edit Date and Time',
                                            style: TextStyle(fontSize: 18)
                                          ),
                                          style: ElevatedButton.styleFrom(primary: Colors.grey)
                                      ),
                                      ElevatedButton(
                                          onPressed: () => saveEventInfo(),
                                          child: Text(
                                              'Save',
                                              style: TextStyle(fontSize: 18)
                                          ),
                                          style: ElevatedButton.styleFrom(primary: Colors.pink[300])
                                      )
                                    ],
                                  )
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

  Future<bool> _getEvent() async {
    var eventRef = store.collection('Events').doc(widget.eventId);
    var eventData = (await eventRef.get()).data();

    _titleController.text = eventData?['name'];
    _descriptionController.text = eventData?['description'];
    _locationController.text = eventData?['location'];
    _date = eventData?['date'].toDate();
    _startTime = eventData?['startTime'].toDate();
    _endTime = eventData?['endTime'].toDate();

    return true;
  }

  void showDateSelection(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel", style: TextStyle(fontSize: 16)),
      onPressed: () {
        closePopup(context);
      },
    );
    Widget saveButton = TextButton(
      child: Text("Save", style: TextStyle(fontSize: 16)),
      onPressed: () {
        saveDate();
        closePopup(context);
        },
    );

    AlertDialog dateAlert = AlertDialog(
      title: const Text("Edit Date and Time"),
      content:
          Container(
            height: 800,
            width: 300,
            child: Column(
              children: <Widget>[
                Container(
                  height: 150,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: _date,
                    onDateTimeChanged: (DateTime newDateTime) {
                      _date = newDateTime;
                    },
                    use24hFormat: false,
                    minuteInterval: 1,
                  )
                ),
                Divider(),
                Text('From', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                    height: 150,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: _startTime,
                      onDateTimeChanged: (DateTime newDateTime) {
                        _startTime = newDateTime;
                      },
                      use24hFormat: false,
                      minuteInterval: 1,
                    )
                ),
                Divider(),
                Text('To', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Container(
                    height: 150,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      initialDateTime: _endTime,
                      onDateTimeChanged: (DateTime newDateTime) {
                        _endTime = newDateTime;
                      },
                      use24hFormat: false,
                      minuteInterval: 1,
                    )
                )
              ],
            )
          ),
      actions: [
        cancelButton,
        saveButton
      ]
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dateAlert;
      }
    );
  }

  Future<void> closePopup(BuildContext context) async {
    Navigator.of(context).pop();
  }

  Future<void> saveDate() async {
    var eventRef = store.collection('Events').doc(widget.eventId);

    await eventRef.update({ 'date': _date, 'startTime': _startTime, 'endTime': _endTime });
  }

  Future<void> saveEventInfo() async {
  var eventRef = store.collection('Events').doc(widget.eventId);

  await eventRef.update({ 'name': _titleController.text, 'description': _descriptionController.text, 'location': _locationController.text });
  openEventsList();
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
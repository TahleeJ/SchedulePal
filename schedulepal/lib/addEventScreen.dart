import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'homeScreen.dart';
import 'package:flutter/cupertino.dart';

/// Stateful class controlling the add course page
class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  // Project's Firebase authentication instance
  var location = "";
  late DateTime date;
  late DateTime savedDate;
  late DateTime startTime;
  late DateTime savedStartTime;
  late DateTime endTime;
  late DateTime savedEndTime;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;

  final newEventNameController = TextEditingController();
  final newEventDescriptionController = TextEditingController();
  final newEventLocationController = TextEditingController();

  @override
    Widget build(BuildContext context) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.greenAccent,
                Colors.yellow,
              ],
            ),
          ),
          child: Card(
            margin: const EdgeInsets.only(top: 145, bottom: 75, left: 30, right: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Create an Event",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    //Sign in button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: newEventNameController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'event name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      child: TextFormField(
                        controller: newEventDescriptionController,
                        decoration: const InputDecoration(
                          border: UnderlineInputBorder(),
                          labelText: 'description',
                        ),
                      ),
                    ),
                    Center(
                      child: RaisedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => chooseLocation(context),
                          );
                        },
                        child: Text(
                          'Add Location',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        )
                      )
                    ),
                    Center(
                        child: RaisedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => chooseDateAndTime(context),
                              );
                            },
                            child: Text(
                              'Add Date & Time',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            )
                        )
                    ),
                    Center(
                        child: RaisedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => showEvents(context),
                              );
                            },
                            child: Text(
                              'curr events',
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            )
                        )
                    ),
                    ElevatedButton(
                        onPressed: () async {
                            var userID = auth.currentUser?.uid;
                            var userRef = await store.collection("User").doc(userID);
                            final CollectionReference eventsRef = FirebaseFirestore.instance.collection('/Events');
                            eventsRef.add({'name' : newEventNameController.text,
                                           'description' : newEventDescriptionController.text,
                                           'location': location,
                                           'date' : savedDate,
                                           'startTime' : savedStartTime,
                                           'endTime' : savedEndTime})
                                .then((value) {
                                  var list = [value.id];
                                  userRef.update({"events": FieldValue.arrayUnion(list)});
                            });
                            goBack(context);
                          },
                        child: Text(
                            "Save",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)
                        )
                    ),
                    ElevatedButton(
                        onPressed: () {goBack(context);},
                        child: Text(
                            "<--",
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal)
                        )
                    ),
                ],
              ),
            ],
          ),
        ),
        ),
      );
  }

Widget chooseDateAndTime(BuildContext context) {
  return new AlertDialog(
    title: const Text('Enter date & time'),
    content: Stack (
      children: <Widget>[
        Container(
          height: 450,
          width: 400,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 300),
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: DateTime(2021, 1, 1),
            onDateTimeChanged: (DateTime newDateTime) {
              date = newDateTime;
            },
            use24hFormat: false,
            minuteInterval: 1,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(105, 155, 0, 0),
          child: const Text(
            "from",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(114, 290, 0, 0),
          child: const Text(
            '''to''',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Wrap(
          spacing: 0.0,
          runSpacing: 0.0,
          children: <Widget>[
            Container(
              height: 300,
              width: 200,
              padding: const EdgeInsets.fromLTRB(50, 170, 0, 0),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2021, 1, 1, 11, 33),
                onDateTimeChanged: (DateTime newDateTime) {
                  startTime = newDateTime;
                },
                use24hFormat: false,
                minuteInterval: 1,
              ),
            ),
            Container(
              height: 300,
              width: 200,
              padding: const EdgeInsets.fromLTRB(50, 0, 0, 150),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2021, 1, 1, 11, 33),
                onDateTimeChanged: (DateTime newDateTime) {
                  endTime = newDateTime;
                },
                use24hFormat: false,
                minuteInterval: 1,
              ),
            )
          ]
        )

      ],
    ),
    actions: <Widget>[
      new FlatButton(
        onPressed: () {
          //actually save values
          savedDate = date;
          savedStartTime = startTime;
          savedEndTime = endTime;
          Navigator.of(context).pop();
        },
        textColor: Theme.of(context).primaryColor,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            child: Text(
              "Save",
            ),
          ),
        ),
      ),
      new FlatButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        textColor: Theme.of(context).primaryColor,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            child: Text(
              "Cancel",
            ),
          ),
        ),
      ),
    ],
  );
}

Widget chooseLocation(BuildContext context) {
    return new AlertDialog(
      title: const Text('Enter a Location'),
      content: Stack (
        children: <Widget> [
          Container(
            height: 450,
            width: 400,
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: TextFormField(
              controller: newEventLocationController,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Address',
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            location = newEventLocationController.text;
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              child: Text(
                "Save",
              ),
            ),
          ),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              child: Text(
                "Cancel",
              ),
            ),
          ),
        ),
      ],
    );
  }

  AlertDialog showEvents(BuildContext context) {
    final result = store.collection('Events');
    int cnt = 0;



    return new AlertDialog(
      title: const Text('Events List'),
      content: Container(
        height: 300.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: FutureBuilder(
          future: getEvents(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              var cnt = ','.allMatches(snapshot.data!["events"].toString()).length + 1;
              var list = [];
              final result = store.collection('Events');

              // return store.collection("Events").doc(firebaseUser).get();
              for (int i = 0; i < cnt; i++) {
                result.get().then((ds) {
                  for (var doc in ds.docs) {
                    if (doc.id == snapshot.data!["events"][i]) {
                      print(doc.get("name"));
                      list.add(doc.get("name"));
                    }
                  }
                  });
                };
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: cnt,
                itemBuilder: (BuildContext context, int index) => Column(
                  children: <Widget>[
                    Text(snapshot.data!["events"][index]),
                    //store.collection("Events").doc(snapshot.data!["events"][index].toString()).get()
                    Text(grabField(snapshot.data!["events"][index].toString())),
                  ],
              ),

              );
                  return Text(snapshot.data!["events"][0]);

            } else if (snapshot.connectionState == ConnectionState.none) {
              return Text("No data");
            }
            return CircularProgressIndicator();
          }
        ),
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () async {
            location = newEventLocationController.text;
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              child: Text(
                "Save",
              ),
            ),
          ),
        ),
        new FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              child: Text(
                "Cancel",
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<DocumentSnapshot> getEvents() async{
    var firebaseUser = await auth.currentUser?.uid;
    return store.collection("User").doc(firebaseUser).get();
  }

  String grabField(String par) {

    return "";
  }

Future<void> goBack(BuildContext context) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen())
    );
 }

}


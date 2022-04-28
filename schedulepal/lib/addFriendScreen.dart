import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'friendsListScreen.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';

/// Stateful class controlling the sign in page
class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({Key? key}) : super(key: key);

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

Future<List<Map<String, dynamic>>>? _usersList = null;

class _AddFriendScreenState extends State<AddFriendScreen> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  var searchString = '';

  @override
  void initState() {
    super.initState();
    _usersList = _fetchUsers();
    print(_usersList);
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
          leading: IconButton(onPressed: () => {openFriendsList()},
              icon: Icon(Icons.arrow_back)),
          actions: <Widget>[
            IconButton(onPressed: () => {goHome()},
                icon: Icon(Icons.home_rounded, size: 26.0),
                tooltip: "Home"),
            IconButton(onPressed: () => {openFriendsList()},
                icon: Icon(Icons.people_alt_outlined, size: 26.0),
                tooltip: "Friend List"),
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
                          "Add Friend",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Divider()
                      ]
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child:
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchString = value.toLowerCase();
                          _usersList = _fetchUsers();
                        });
                      },
                      decoration: InputDecoration(
                          labelText: 'Search (e.g., \'John Smith\')',
                          suffixIcon: Icon(Icons.search)),
                    ),

                  ),
                  FutureBuilder(
                      future: _usersList,
                      builder: (context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return CircularProgressIndicator();
                          case ConnectionState.done:
                            if (snapshot.hasData && snapshot.data!.length > 0) {
                              return Container(
                                  height: 400,
                                  child: ListView.builder(
                                      padding: EdgeInsets.all(15.0),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (BuildContext context,
                                          int index) {
                                        return _buildUser(
                                            snapshot.data![index]["uid"],
                                            snapshot.data![index]["name"]
                                        );
                                      }
                                  )
                              );
                            } else {
                              return Text(
                                  "No Users",
                                  style: TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.bold));
                            }

                          default:
                            return Text(
                                "No Users",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold));
                        }
                      }
                  )
                ],
              ),
            )
        )
    );
  }

  /// Navigates back to the home screen
  void goHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    var userRef = store.collection('User').where(
        "name", isGreaterThanOrEqualTo: searchString);
    // var userRef = store.collection('User');
    var userSnapshot = (await userRef.get()).docs;

    List<Map<String, dynamic>> friendsList = [];

    userSnapshot.forEach((snapshot) async {
      print(snapshot.data()["name"]);
      friendsList.add(Map.fromIterables(
          ["uid", "name"], [snapshot.id, snapshot.data()["name"]]));
    });

    await Future.delayed(Duration(milliseconds: 1000));

    return friendsList;
  }

  Widget _buildUser(String uid, String name) {
    bool _isRemoved = false;
    IconData _friendButton = Icons.add_circle_outline;

    if (!_isRemoved) {
      print(name);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          StatefulBuilder(builder: (context, _setState) =>
              Container(
                  decoration: BoxDecoration(
                      color: Colors.pinkAccent,
                      border: Border.all(color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  child: Padding(
                      padding: EdgeInsets.only(
                          right: 20.0, left: 20.0, top: 10.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(right: 15.0),
                              child: CircleAvatar(
                                  child: Icon(Icons.person, size: 15,
                                      color: Colors.grey),
                                  backgroundColor: Colors.white
                              )
                          ),
                          Padding(
                              padding: EdgeInsets.only(right: 15.0),
                              child: Text(name, style: TextStyle(
                                  fontSize: 20, color: Colors.white))
                          ),
                          Spacer(),
                          GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _setState(() {
                                  // _isRemoved = true;
                                  _handleAddFriend(uid);
                                  _friendButton = Icons.check_circle_outline;
                                });
                              },
                              child: Icon(_friendButton, size: 30,
                                  color: Colors.black45)
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
        ],
      );
    }
  }
  Future<void> _handleAddFriend(String uid) async {
    inspect("add friend");
    inspect(uid);
    var userId = auth.currentUser!.uid;

    var userRef = store.collection("User").doc(uid);
    Map<String, dynamic> friendsList = (await userRef.get())
        .data()!["friends"];
    friendsList.addAll(Map.fromIterables([userId], [1]));
    await userRef.update({"friends": friendsList});

    userRef = store.collection("User").doc(userId);
    friendsList = (await userRef.get()).data()!["friends"];
    friendsList.addAll(Map.fromIterables([uid], [2]));
    await userRef.update({"friends": friendsList});
  }

  /// Signs out the currently signed in user and navigates to the sign in screen
  Future<void> _signOut() async {
    await auth.signOut();
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    goSignIn();
  }

  void openFriendsList() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FriendsListScreen()));
  }

  /// Navigates to the sign in screen
  void goSignIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';
import 'addFriendScreen.dart';
import 'friendsPendingScreen.dart';

/// Stateful class controlling the sign in page
class FriendsListScreen extends StatefulWidget {
  const FriendsListScreen({Key? key}) : super(key: key);

  @override
  _FriendsListScreenState createState() => _FriendsListScreenState();
}

class _FriendsListScreenState extends State<FriendsListScreen> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Builder for the homepage screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Colors.pink,
          centerTitle: true,
          title: const Text("Schedule Pal"),
          actions: <Widget>[
            // Sign out button
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  // Sign out the user and navigate to the sign in screen upon being clicked
                    onTap: () { _signOut(); },
                    child: Icon(Icons.exit_to_app_outlined, size: 26.0),
                )
            )
          ]
      ),
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
          margin: const EdgeInsets.only(top: 50, bottom: 50, left: 20, right: 20),
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              StatefulBuilder(builder: (context, _setState) {
                return Row(
                    children: <Widget>[
                      SizedBox(width: 20),
                      ElevatedButton(
                          onPressed: () {goHome();},
                          child: Text("<--", style: TextStyle(fontSize: 24))
                      ),
                      SizedBox(width: 15),
                      Text(
                        "Friends List",
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                          onTap: () {
                            _setState(() {
                              openFriendsPendingList();
                            });
                          },
                          child: Icon(Icons.hourglass_bottom_rounded, size: 30, color: Colors.blueGrey)
                      )
                    ]
                );
              }),

              FutureBuilder(
                  future: _getFriendsList(),
                  builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        height: 300,
                        child: ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return _buildFriend(
                                snapshot.data![index]["uid"],
                                snapshot.data![index]["name"]
                            );
                          }
                      )
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  }
              )
            ],
          ),
        )

      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
              right: 10,
              bottom: 20,
              child: FloatingActionButton(
                heroTag: "addFriendButton",
                // Navigate to the create task page upon pressing the button
                onPressed: goAddFriend,
                child: const Icon(Icons.person_add_alt_outlined),
                backgroundColor: Colors.pink,
              )
          ),
          Positioned(
              right: 100,
              left: 100,
              bottom: 20,
              child: FloatingActionButton(
                heroTag: "homeButton",
                // Navigate to the create task page upon pressing the button
                onPressed: goHome,
                child: const Icon(Icons.home),
                backgroundColor: Colors.pink,
              )
          ),
        ]
      )
    );
  }

  /// Navigates back to the home screen
  void goHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  void goAddFriend() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => AddFriendScreen()));
  }

  Future<List<Map<String, dynamic>>> _getFriendsList() async {
    var userRef = store.collection('User').doc(auth.currentUser?.uid);
    var userSnapshot = await userRef.get();
    var userCollection = store.collection("User");

    Map<String, dynamic> friends;

    // List to structurally hold all of a user's tasks in maps:
    // {name: task's name},
    // {latitude: task location's latitude},
    // {longitude: task location's longitude}
    List<Map<String, dynamic>> friendsList = [];

    if (userSnapshot.exists) {
      friends = userSnapshot.data()!["friends"];
      friends.forEach((key, mapValue) async {
        if (mapValue == 0) {
          friendsList.add(Map.fromIterables(["uid", "name"], [key, (await userCollection.doc(key).get()).data()?["name"]]));
        }
      });
    }

    return friendsList;
  }

  Widget _buildFriend(String uid, String name) {
    bool _isRemoved = false;

    if (!_isRemoved) {
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
                          ),
                          GestureDetector(
                              onTap: () {
                                _setState(() {
                                  _isRemoved = true;
                                  _handleRemoveFriend(uid);
                                });
                              },
                              child: Icon(Icons.highlight_remove_rounded, size: 30, color: Colors.black45)
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

  Future<void> _handleRemoveFriend(String uid) async {
    var userId = auth.currentUser?.uid;

    var userRef = store.collection("User").doc(uid);
    Map<String, dynamic> friendsList = (await userRef.get()).data()!["friends"];
    friendsList.remove(userId);
    await userRef.update({"friends": friendsList});

    userRef = store.collection("User").doc(userId);
    friendsList = (await userRef.get()).data()!["friends"];
    friendsList.remove(uid);
    await userRef.update({"friends": friendsList});
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

  void openFriendsPendingList() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => FriendsPendingScreen()));
  }
}

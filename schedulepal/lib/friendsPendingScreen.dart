import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'friendsListScreen.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';

/// Stateful class controlling the sign in page
class FriendsPendingScreen extends StatefulWidget {
  const FriendsPendingScreen({Key? key}) : super(key: key);

  @override
  _FriendsPendingScreenState createState() => _FriendsPendingScreenState();
}

class _FriendsPendingScreenState extends State<FriendsPendingScreen> {
  // Project's Firebase authentication instance
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  /// Builder for the homepage screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.pink[300],
          centerTitle: true,
          title: const Text("Schedule Pal"),
          leading: IconButton(onPressed: () =>{openFriendsList()}, icon: Icon(Icons.arrow_back),),
          actions: <Widget>[
            // Sign out button

            IconButton(onPressed: () => {}, icon: Icon(Icons.exit_to_app_outlined, size: 26.0, ),
              tooltip: "Sign Out",)

          ],
        ),
        body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white
            ),
            child: Card(
              margin: const EdgeInsets.only(top: 50, bottom: 50, left: 20, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                      children: <Widget>[
                        Text(
                          "Manage Requests",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ]
                  ),
                  Row(
                      children: <Widget>[
                        SizedBox(width: 15),
                        Text(
                          "Incoming Requests",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ]
                  ),
                  FutureBuilder(
                    future: _getRequests(1),
                    builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          height: 175,
                          child: ListView.builder(
                            padding: EdgeInsets.all(10.0),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return _buildIncomingRequest(
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
                  ),
                  Row(
                      children: <Widget>[
                        SizedBox(width: 15),
                        Text(
                          "Outgoing Requests",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ]
                  ),
                  FutureBuilder(
                    future: _getRequests(2),
                    builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          inspect("has data check");
                          inspect(snapshot.data!.length);
                          return Container(
                              height: 175,
                              child: ListView.builder(
                                  padding: EdgeInsets.all(10.0),
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    inspect("outgoing builder reached");
                                    return _buildOutgoingRequest(
                                        snapshot.data![index]["uid"],
                                        snapshot.data![index]["name"]
                                    );
                                  }
                              )
                          );
                        } else {
                          return const Text("No requests!");
                        }
                      } else {
                        return const CircularProgressIndicator();
                      }
                    }
                  )
                ]
              )
            )
        ),
        floatingActionButton: Stack(
            children: [
              Positioned(
                  right: 100,
                  left: 100,
                  bottom: 20,
                  child: FloatingActionButton(
                    heroTag: "addFriendButton",
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

  Future<List<Map<String, dynamic>>> _getRequests(int type) async {
    var userRef = store.collection('User').doc(auth.currentUser!.uid);
    var userSnapshot = await userRef.get();

    var userCollection = store.collection("User");
    Map<String, dynamic> friends;

    // List to structurally hold all of a user's tasks in maps:
    List<Map<String, dynamic>> requestList = [];

    if (userSnapshot.exists) {
      friends = userSnapshot.data()!["friends"];
      // inspect(friends);
      friends.forEach((key, mapValue) async {
        // inspect(mapValue);
        if (mapValue == type) {
          var userDoc = await userCollection.doc(key).get();
          requestList.add(Map.fromIterables(["uid", "name"], [key, userDoc.data()!["name"]]));
        }
      });
    }

    return requestList;
  }

  Widget _buildIncomingRequest(String uid, String name) {
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
                                _setState(() {
                                  _isRemoved = true;
                                  _handleAcceptIncoming(uid);
                                });
                              },
                              child: Icon(Icons.check_circle_outline_rounded, size: 30, color: Colors.black45)
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

  Widget _buildOutgoingRequest(String uid, String name) {
    bool _isRemoved = false;

    if (!_isRemoved) {
      // inspect("reached");
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
                          Icon(Icons.hourglass_bottom_rounded, size: 30, color: Colors.black45),
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
    var userId = auth.currentUser!.uid;

    // Remove current user from old friend's friends list
    var userRef = store.collection("User").doc(uid);
    Map<String, dynamic> friendsList = (await userRef.get()).data()!["friends"];
    friendsList.remove(userId);
    await userRef.update({"friends": friendsList});

    // Remove old friend from current user's friends list
    userRef = store.collection("User").doc(userId);
    friendsList = (await userRef.get()).data()!["friends"];
    friendsList.remove(uid);
    await userRef.update({"friends": friendsList});
  }

  Future<void> _handleAcceptIncoming(String uid) async {
    var userId = auth.currentUser!.uid;

    var userRef = store.collection("User").doc(uid);
    Map<String, dynamic> friendsList = (await userRef.get()).data()!["friends"][userId];
    friendsList.addAll(Map.fromIterables(["status"], [0]));
    await userRef.update({"friends": friendsList});

    userRef = store.collection("User").doc(userId);
    friendsList = (await userRef.get()).data()!["friends"][uid];
    friendsList.addAll(Map.fromIterables(["status"], [0]));
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
        context, MaterialPageRoute(builder: (context) => FriendsListScreen()));
  }

  /// Navigates to the sign in screen
  void goSignIn() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));
  }
}

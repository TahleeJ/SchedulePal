import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

Future<List<Map<String, dynamic>>>? _incomingList = null;
Future<List<Map<String, dynamic>>>? _outgoingList = null;

class _FriendsPendingScreenState extends State<FriendsPendingScreen> {
  // Project's Firebase authentication instance
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _incomingList = _getRequests(1);
    _outgoingList = _getRequests(2);
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
          leading: IconButton(onPressed: () =>{openFriendsList()}, icon: Icon(Icons.arrow_back),),
          actions: <Widget>[
            IconButton(onPressed: () => {goHome()}, icon: Icon(Icons.home_rounded, size: 26.0), tooltip: "Home"),
            IconButton(onPressed: () => {openFriendsList()}, icon: Icon(Icons.people_alt_outlined, size: 26.0), tooltip: "Friends List"),
            IconButton(onPressed: () => {_signOut()}, icon: Icon(Icons.exit_to_app_outlined, size: 26.0),
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
                            "Manage Requests",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          )
                        ]
                    ),
                  Divider(),
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
                    future: _incomingList,
                    builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.active:
                        case ConnectionState.waiting:
                          return const CircularProgressIndicator();
                        case ConnectionState.done:
                          if (snapshot.hasData) {
                            return Container(
                                height: MediaQuery.of(context).size.height / 3,
                                child: (snapshot.data!.length > 0) ?
                                  ListView.builder(
                                    padding: EdgeInsets.all(10.0),
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      return _buildIncomingRequest(
                                          snapshot.data![index]["uid"],
                                          snapshot.data![index]["name"]
                                      );
                                    }
                                ) : Text(
                                  "No Requests",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                )
                            );
                          } else {
                            return Text(
                              "No Requests",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            );
                          }
                        default:
                          return Text(
                            "No Requests",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          );
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
                      future: _outgoingList,
                      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.active:
                          case ConnectionState.waiting:
                            return const CircularProgressIndicator();
                          case ConnectionState.done:
                            if (snapshot.hasData && snapshot.data!.length > 0) {
                              return Container(
                                  height: MediaQuery.of(context).size.height / 3,
                                  child: (snapshot.data!.length > 0) ?
                                  ListView.builder(
                                      padding: EdgeInsets.all(10.0),
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return _buildOutgoingRequest(
                                            snapshot.data![index]["uid"],
                                            snapshot.data![index]["name"]
                                        );
                                      }
                                  ) : Text(
                                    "No Requests",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  )
                              );
                            } else {
                              return Text(
                                "No Requests",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              );
                            }
                          default:
                            return Text(
                              "No Requests",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            );
                        }
                      }
                  )
                ]
              )
            )
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

      await Future.forEach(friends.entries, (element) async {
        MapEntry<String, dynamic> friendEntry = element as MapEntry<String, dynamic>;
        int friendType = (friendEntry.value as num).toInt();

        if (friendType == type) {
          var friendData = (await userCollection.doc(friendEntry.key).get()).data();

          requestList.add(Map.fromIterables(["uid", "name"], [friendEntry.key, friendData?["name"]]));
        }
      });
    }

    await Future.delayed(Duration(milliseconds: 2000));

    return requestList;
  }

  Widget _buildIncomingRequest(String uid, String name) {
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
                                _setState(() {
                                  _isRemoved = true;
                                  _handleAcceptIncoming(uid);
                                });
                              },
                              child: Icon(!_isRemoved ? Icons.check_circle_outline_rounded : null, size: 30, color: Colors.black45)
                          ),
                          GestureDetector(
                              onTap: () {
                                _setState(() {
                                  _isRemoved = true;
                                  _handleRemoveFriend(uid);
                                });
                              },
                              child: Icon(!_isRemoved ? Icons.highlight_remove_rounded : null, size: 30, color: Colors.black45)
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

  Widget _buildOutgoingRequest(String uid, String name) {
    bool _isRemoved = false;

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
                              child: Icon(!_isRemoved ? Icons.highlight_remove_rounded : null, size: 30, color: Colors.black45)
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

    _incomingList = _getRequests(1);
    _outgoingList = _getRequests(2);
  }

  Future<void> _handleAcceptIncoming(String uid) async {
    var userId = auth.currentUser!.uid;

    var userRef = store.collection("User").doc(uid);
    Map<String, dynamic> friendsList = (await userRef.get()).data()!["friends"];
    friendsList[userId] = 0;
    await userRef.update({"friends": friendsList});

    userRef = store.collection("User").doc(userId);
    friendsList = (await userRef.get()).data()!["friends"];
    friendsList[uid] = 0;
    await userRef.update({"friends": friendsList});

    _incomingList = _getRequests(1);
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

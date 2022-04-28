import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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

Future<List<Map<String, dynamic>>>? _friendsList = null;

class _FriendsListScreenState extends State<FriendsListScreen> {
  // Project's Firebase Build feature instances
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _friendsList = _getFriendsList();
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
            IconButton(onPressed: () =>{openFriendsPendingList()}, icon: Icon(Icons.hourglass_bottom_rounded, size: 30), tooltip: "Pending Friends"),
            IconButton(onPressed: () => {_signOut()}, icon: Icon(Icons.exit_to_app_outlined, size: 26.0), tooltip: "Sign Out")

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
                        "Friends List",
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
                        if (snapshot.hasData && snapshot.data!.length > 0) {
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
                          return Text(
                            "No Friends :(",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          );
                        }
                      default:
                        return Text(
                          "No Friends :(",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        );
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
          )
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
    var userCollection = store.collection('User');
    var userSnapshot = await userCollection.doc(auth.currentUser?.uid).get();

    Map<String, dynamic> friends;

    // List to structurally hold all of a user's tasks in maps:
    // {name: task's name},
    // {latitude: task location's latitude},
    // {longitude: task location's longitude}
    List<Map<String, dynamic>> friendsList = [];

    if (userSnapshot.exists) {
      friends = userSnapshot.data()!["friends"];

      await Future.forEach(friends.entries, (element) async {
        MapEntry<String, dynamic> friendEntry = element as MapEntry<String, dynamic>;
        int friendType = (friendEntry.value as num).toInt();

        if (friendType == 0) {
          var friendData = (await userCollection.doc(friendEntry.key).get()).data();

          friendsList.add(Map.fromIterables(["uid", "name"], [friendEntry.key, friendData?["name"]]));
        }
      });
    }
    
    await Future.delayed(Duration(milliseconds: 2000));

    return friendsList;
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
        ]
      );
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

    _friendsList = _getFriendsList();
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

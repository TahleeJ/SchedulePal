import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'signInScreen.dart';
import 'homeScreen.dart';

/// Stateful class controlling the sign in page
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>{
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  final newNameController = TextEditingController();
  final newEmailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,

          // gradient: LinearGradient(
          //   colors: [
          //     Colors.blue,
          //     Colors.greenAccent,
          //     Colors.yellow,
          //   ],

        ),
        // Card containing app name and sign in button
        child: Card(
          margin: const EdgeInsets.only(top: 155, bottom: 75, left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Create an Account",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: TextFormField(
                      controller: newNameController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Firstname Lastname',
                      ),
                    ),
                  ),
                  //Sign in button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: TextFormField(
                      controller: newEmailController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: TextFormField(
                      controller: newPasswordController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'password',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    child: TextFormField(
                      controller: confirmNewPasswordController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 're-enter password',
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {createAccount(context, newEmailController.text, newPasswordController.text, confirmNewPasswordController.text, newNameController.text);},
                      child: Text(
                          "Create",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal)
                      ),
                    style: ElevatedButton.styleFrom(primary: Colors.pink[300]),
                  ),
                  ElevatedButton(
                      onPressed: () {goBack(context);},
                      child: Text(
                          "<--",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal)
                      ),
                    style: ElevatedButton.styleFrom(primary: Colors.pink[300]),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createAccount(BuildContext context, email, String password, String confirmPassword, String nameEntered) async {
    if (password == "" || confirmPassword == "") {
      passwordEmpty();
    } else if (password.compareTo(confirmPassword) != 0) {
      passwordsDontMatch();
    } else {
      try {
        var userCred = await auth.createUserWithEmailAndPassword(email: email, password: password.toString());
        var displayName = userCred.user!.displayName?.toLowerCase().split(" ");
        var name = "${displayName?.first} ${displayName?.last}";

        var userRef = await store.collection("User").doc(userCred.user!.uid);
        if (!(await userRef.get()).exists) {
          if (name == "null null") {
            await userRef.set({"name": nameEntered, "friends": {}, "events": {}}, SetOptions(merge: false));
          } else {
            await userRef.set({"name": name, "friends": {}}, SetOptions(merge: false));
          }
        }

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));;
      } on FirebaseAuthException catch (e) { }
    }
  }

  Future<void> goBack(BuildContext context) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignInScreen()));;
  }

  Future<void> passwordsDontMatch() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Passwords do not match'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> passwordEmpty() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Missing password field'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
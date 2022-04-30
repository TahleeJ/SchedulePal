import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'homeScreen.dart';
import 'signUpScreen.dart';

/// Stateful class controlling the sign in page
class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
          // ),
        ),
        // Card containing app name and sign in button
        child: Card(
          margin: const EdgeInsets.only(top: 175, bottom: 105, left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text(
                "Schedule Pal!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Sign in button
                  ElevatedButton(
                    onPressed: () {googleSignIn(context);},
                    child: Text(
                      "Sign in with Google",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.pink[300]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'password',
                      ),
                      obscureText: true,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {emailSignIn(context, emailController.text, passwordController.text);},
                      child: Text(
                          "Log in",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)
                      ),
                    style: ElevatedButton.styleFrom(primary: Colors.pink[300]),
                  ),
                  TextButton(
                      onPressed: () {signUp(context);},
                    child: Text('Create an Account'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                      primary: Colors.blueAccent,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Signs in a user
  Future<void> googleSignIn(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
      final AuthCredential authCredential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      // Gets a user's credentials
      UserCredential result = await auth.signInWithCredential(authCredential);
      User? user = result.user;

      // Navigates to the home page screen once the user has signed in
      if (result != null) {
        var displayName = user!.displayName?.toLowerCase().split(" ");
        var name = "${displayName?.first} ${displayName?.last}";

        var userRef = await store.collection("User").doc(user.uid);
        if (!(await userRef.get()).exists) {
          await userRef.set({"name": name, "friends": {}}, SetOptions(merge: false));
        }
        
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    }
  }

  Future<void> emailSignIn(BuildContext context, email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));;
    } on FirebaseAuthException catch (e) { }
  }

  Future<void> signUp(BuildContext context) async {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => SignUpScreen()));;
  }
}

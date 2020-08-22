import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stuxplay/resources/auth_methods.dart';
import 'package:stuxplay/utils/palette.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  AuthMethods _auth = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.blackColor,
      body: loginButton(),
    );
  }

  Widget loginButton() {
    return FlatButton(
      padding: EdgeInsets.all(35),
      child: Center(
        child: Text(
          "LOGIN",
          style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2),
        ),
      ),
      onPressed: () => performLogin(),
    );
  }

  void performLogin() {
    print("trying to perform login");
    _auth.signIn().then((FirebaseUser user) {
      print("something");
      if (user != null) {
        authenticateUser(user);
      } else {
        print("There was an error");
      }
    });
  }

  void authenticateUser(FirebaseUser user) {
    _auth.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        _auth.addDataToDb(user).then((value) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}

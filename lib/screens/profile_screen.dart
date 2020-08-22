import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stuxplay/models/user.dart';
import 'package:stuxplay/provider/user_provider.dart';
import 'package:stuxplay/resources/auth_methods.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProvider _userProvider;
  AuthMethods _authMethods = AuthMethods();
  User currentUser;

  createProfileTopView() {
    _authMethods.getCurrentUser().then((user) {
      setState(() {
        currentUser.uid = user.uid;
      });
    });
    _userProvider = Provider.of<UserProvider>(context);
    print(_userProvider.getUser.uid);
    return FutureBuilder(
      future: _authMethods.getUserDetailsById(_userProvider.getUser.uid),
      builder: (context, dataSnapshot) {
        if (!dataSnapshot.hasData) {
          return CircularProgressIndicator();
        }

        User user = User.fromMap(dataSnapshot.data);
        return Padding(
          padding: EdgeInsets.all(17.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 45.0,
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(user.profilePhoto),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        createColumns('Views', 0),
                        createColumns('Followers', 0),
                        createColumns('Following', 0),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        createButton(),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Column createColumns(String title, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
    );
  }

  createButton() {
    bool ownProfile = currentUser.uid == _userProvider.getUser.uid;
    if (ownProfile) {
      return RaisedButton(
        onPressed: () {},
        child: Text('Edit Profile'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Header'),
      ),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
        ],
      ),
    );
  }
}

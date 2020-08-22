import 'package:flutter/widgets.dart';
import 'package:stuxplay/models/user.dart';
import 'package:stuxplay/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  User _user;
  AuthMethods _auth = AuthMethods();

  User get getUser => _user;

  void refreshUser() async {
    User user = await _auth.getUserDetails();
    _user = user;
    notifyListeners();
  }
}

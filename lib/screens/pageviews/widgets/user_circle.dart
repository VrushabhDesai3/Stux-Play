import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stuxplay/provider/user_provider.dart';
import 'package:stuxplay/utils/palette.dart';
import 'package:stuxplay/utils/utilities.dart';

class UserCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserProvider userProvider = Provider.of<UserProvider>(context);
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Palette.separatorColor,
      ),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text(
              Utils.getInitials(userProvider.getUser.name),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Palette.lightBlueColor,
                fontSize: 13,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Palette.blackColor, width: 2),
                color: Palette.onlineDotColor,
              ),
            ),
          )
        ],
      ),
    );
  }
}

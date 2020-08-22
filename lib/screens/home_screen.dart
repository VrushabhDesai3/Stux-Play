import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:stuxplay/provider/user_provider.dart';
import 'package:stuxplay/screens/callscreens/pickup/pickup_layout.dart';
import 'package:stuxplay/screens/pageviews/chat_list_screen.dart';
import 'package:stuxplay/screens/profile_screen.dart';
import 'package:stuxplay/screens/temporary.dart';
import 'package:stuxplay/screens/uploadscreens/upload_screen.dart';
import 'package:stuxplay/utils/palette.dart';
import 'package:stuxplay/resources/auth_methods.dart';
import 'package:stuxplay/enum/user_state.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  UserProvider userProvider;

  final AuthMethods _authMethods = AuthMethods();

  PageController pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();

      _authMethods.setUserState(
          userId: userProvider.getUser.uid, userState: UserState.Online);
    });

    WidgetsBinding.instance.addObserver(this);

    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        (userProvider != null && userProvider.getUser != null)
            ? userProvider.getUser.uid
            : "";

    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print("resume state");
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("inactive state");
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print("paused state");
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print("detached state");
        break;
    }
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  Widget build(BuildContext context) {
    double _labelFontSize = 10;
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: Palette.blackColor,
        body: PageView(
          children: <Widget>[
            Temporary(),
            Center(
              child:
                  Text('Search Screen', style: TextStyle(color: Colors.white)),
            ),
            Center(
              child: UploadScreen(),
            ),
            Container(
              child: ChatListScreen(),
            ),
            Center(child: ProfileScreen()),
          ],
          controller: pageController,
          onPageChanged: onPageChanged,
          physics: NeverScrollableScrollPhysics(),
        ),
        bottomNavigationBar: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CupertinoTabBar(
              backgroundColor: Palette.blackColor,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.home,
                        size: 25.0,
                        color: (_page == 0)
                            ? Palette.lightBlueColor
                            : Palette.greyColor),
                  ),
                  title: Text(
                    "Home",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 0)
                            ? Palette.lightBlueColor
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.call,
                        size: 25.0,
                        color: (_page == 1)
                            ? Palette.lightBlueColor
                            : Palette.greyColor),
                  ),
                  title: Text(
                    "Calls",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 1)
                            ? Palette.lightBlueColor
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.add,
                        size: 25.0,
                        color: (_page == 2)
                            ? Palette.lightBlueColor
                            : Palette.greyColor),
                  ),
                  title: Text(
                    "Upload",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 2)
                            ? Palette.lightBlueColor
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.chat,
                        size: 25.0,
                        color: (_page == 3)
                            ? Palette.lightBlueColor
                            : Palette.greyColor),
                  ),
                  title: Text(
                    "Chats",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 3)
                            ? Palette.lightBlueColor
                            : Colors.grey),
                  ),
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Icon(Icons.person,
                        size: 25.0,
                        color: (_page == 4)
                            ? Palette.lightBlueColor
                            : Palette.greyColor),
                  ),
                  title: Text(
                    "Profile",
                    style: TextStyle(
                        fontSize: _labelFontSize,
                        color: (_page == 4)
                            ? Palette.lightBlueColor
                            : Colors.grey),
                  ),
                ),
              ],
              onTap: navigationTapped,
              currentIndex: _page,
            ),
          ),
        ),
      ),
    );
  }
}

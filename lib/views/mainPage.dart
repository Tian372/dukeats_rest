import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/providers/userLogin.dart';
import 'package:Dukeats/views/postList.dart';
import 'package:Dukeats/views/restaurantView.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authView.dart';
import 'infoView.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  List<Widget> _children = [
    RestaurantView(),
    PostList(),
    InfoView(),
  ];
  List<Widget> _title = [
    Text(AppLocalizations.instance.text('task_text')),
    Text(AppLocalizations.instance.text('post_text')),
    Text(AppLocalizations.instance.text('info_text')),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLoginProvider = Provider.of<UserLogin>(context);
    return !userLoginProvider.loginStatus ? Authenticate() : navigation();
  }

  Widget navigation() {
    void onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: _title[_currentIndex],
      ),
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text(AppLocalizations.instance.text('task_text')),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.line_weight),
            title: Text(AppLocalizations.instance.text('post_text')),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text(AppLocalizations.instance.text('info_text')),
          ),
        ],
      ),
    );
  }
}

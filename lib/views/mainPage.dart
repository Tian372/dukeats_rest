import 'package:Dukeats/localization/application.dart';
import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/providers/userLogin.dart';
import 'package:Dukeats/views/qrCodeScanner.dart';
import 'package:Dukeats/views/orderHistoryView.dart';
import 'package:Dukeats/views/postView.dart';
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



  @override
  void initState() {
    super.initState();
    // application.onLocaleChanged = onLocaleChange;
    // onLocaleChange(Locale(languagesMap["Chinese"]));
    WidgetsBinding.instance.addObserver(this);
  }
  // void onLocaleChange(Locale locale) async {
  //   setState(() {
  //     AppLocalizations.load(locale);
  //   });
  // }

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

    List<Widget> _children = [
      RestaurantView(),
      PostView(),
      OrderHistoryView(),
      InfoView(),
    ];

    void onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: _title[_currentIndex],
      //   actions: <Widget>[
      //     PopupMenuButton<String>(
      //       // overflow menu
      //       onSelected: _select,
      //       icon: new Icon(Icons.language, color: Colors.white),
      //       itemBuilder: (BuildContext context) {
      //         return languagesList
      //             .map<PopupMenuItem<String>>((String choice) {
      //           return PopupMenuItem<String>(
      //             value: choice,
      //             child: Text(choice),
      //           );
      //         }).toList();
      //       },
      //     ),
      //   ],
      // ),
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: Colors.blue,
        unselectedItemColor: Colors.black26,
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context).text('task_text'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: AppLocalizations.of(context).text('post_text'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: AppLocalizations.of(context).text('history_text'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: AppLocalizations.of(context).text('info_text'),
          ),
        ],
      ),
    );
  }


  PopupMenuButton<String> languagePicker(){

  }
}

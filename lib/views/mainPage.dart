import 'package:Dukeats/localization/application.dart';
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
  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList =
      application.supportedLanguagesCodes;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };

  String label = languagesList[0];

  int _currentIndex = 0;



  @override
  void initState() {
    super.initState();
    application.onLocaleChanged = onLocaleChange;
    onLocaleChange(Locale(languagesMap["Chinese"]));
    WidgetsBinding.instance.addObserver(this);
  }
  void onLocaleChange(Locale locale) async {
    setState(() {
      AppLocalizations.load(locale);
    });
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
    List<Widget> _title = [
      Text(AppLocalizations.of(context).text('task_text')),
      Text(AppLocalizations.of(context).text('post_text')),
      Text(AppLocalizations.of(context).text('info_text')),
    ];
    List<Widget> _children = [
      RestaurantView(),
      PostList(),
      InfoView(),
    ];

    void onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }
    void _select(String language) {
      print("dd "+language);
      onLocaleChange(Locale(languagesMap[language]));
      setState(() {
        if (language == "Chinese") {
          label = "中文";
        } else {
          label = language;
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: _title[_currentIndex],
        actions: <Widget>[
          PopupMenuButton<String>(
            // overflow menu
            onSelected: _select,
            icon: new Icon(Icons.language, color: Colors.white),
            itemBuilder: (BuildContext context) {
              return languagesList
                  .map<PopupMenuItem<String>>((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text(AppLocalizations.of(context).text('task_text')),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.line_weight),
            title: Text(AppLocalizations.of(context).text('post_text')),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text(AppLocalizations.of(context).text('info_text')),
          ),
        ],
      ),
    );
  }
}

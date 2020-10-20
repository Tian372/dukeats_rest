import 'package:Dukeats/localization/application.dart';
import 'package:Dukeats/localization/localization.dart';
import 'package:flutter/material.dart';

class InfoView extends StatefulWidget {
  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList =
      application.supportedLanguagesCodes;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };

  String label = languagesList[0];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    application.onLocaleChanged = onLocaleChange;
    onLocaleChange(Locale(languagesMap["English"]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
        actions: <Widget>[
          PopupMenuButton<String>(
            // overflow menu
            onSelected: _select,
            icon: new Icon(Icons.language, color: Colors.white),
            itemBuilder: (BuildContext context) {
              return languagesList.map<PopupMenuItem<String>>((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SafeArea(
          child: Container(
        child: restaurantInfo(),
      )),
    );
  }

  void onLocaleChange(Locale locale) async {
    setState(() {
      AppLocalizations.load(locale);
    });
  }

  void _select(String language) {
    onLocaleChange(Locale(languagesMap[language]));
    setState(() {
      if (language == "Chinese") {
        label = "中文";
      } else {
        label = language;
      }
    });
  }

  Widget restaurantInfo() {
    Future<Map<String, String>> myTypedFuture() async {
      await Future.delayed(Duration(seconds: 1));
      var restaurant = new Map<String, String>();
      restaurant['name'] = 'cool restaurant';
      restaurant['number'] = '12345678';
      restaurant['address'] = 'My address, NC, 27705';
      restaurant['sell'] = '3000';
      return restaurant;
    }

    return FutureBuilder(
      future: myTypedFuture(),
      builder: (context, snapshot) {
        var restaurant = new Map<String, String>();
        if (snapshot.hasData) {
          restaurant = snapshot.data;
        }
        return snapshot.hasData
            ? Center(
                child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(20),
                childAspectRatio: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 1,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                        child: Text(
                            '${AppLocalizations.of(context).text('name_text')}: ${restaurant['name']}')),
                    color: Colors.teal[100],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                        child: Text(
                            '${AppLocalizations.of(context).text('phone_text')}: ${restaurant['number']}')),
                    color: Colors.teal[200],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                        child: Text(
                            '${AppLocalizations.of(context).text('address_text')}: ${restaurant['address']}')),
                    color: Colors.teal[300],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                        child: Text(
                            '${AppLocalizations.of(context).text('sell_text')}: ${restaurant['sell']}')),
                    color: Colors.teal[400],
                  ),
                ],
              ))
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

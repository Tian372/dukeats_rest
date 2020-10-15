import 'package:Dukeats/localization/localization.dart';
import 'package:flutter/material.dart';
import 'package:Dukeats/providers/userLogin.dart';
import 'package:Dukeats/views/post.dart';
import 'package:provider/provider.dart';

import 'menuPost.dart';

class PostView extends StatefulWidget {
  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double fontsize = 35;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).text('post_text')),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(
                    Radius.circular(5.0) //         <--- border radius here
                    ),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) => MenuPost()));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.photo,
                      size: fontsize,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppLocalizations.of(context).text('add_menu_text'),
                      style: TextStyle(fontSize: fontsize),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.all(
                    Radius.circular(5.0) //         <--- border radius here
                    ),
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                          builder: (BuildContext context) => Post()));
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: fontsize,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppLocalizations.of(context).text('post_today_text'),
                      style: TextStyle(fontSize: fontsize),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}

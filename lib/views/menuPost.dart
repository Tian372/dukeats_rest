import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MenuPost extends StatefulWidget {
  @override
  _MenuPostState createState() => _MenuPostState();
}

class _MenuPostState extends State<MenuPost> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).text('post_today_text')),
        ),
        body: SafeArea(child: MenuForm()));
  }
}

class MenuForm extends StatefulWidget {
  @override
  MenuFormState createState() {
    return MenuFormState();
  }
}

// final String menuName;
// final double price;
// final String description;
// final List<String> items;
// final String restaurantName;

class MenuFormState extends State<MenuForm> {
  Menu menu = Menu();
  final _formKey = GlobalKey<FormState>();
  int _amount = 0;


  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                labelText: 'MenuName'),
            onSaved: (val) {
              menu.menuName = val;
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                labelText: 'Price'),
            onSaved: (val) {
              menu.price = int.parse(val);
            },
          ),
          TextFormField(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0)),
                labelText: 'Description'),
            onSaved: (val) {
              menu.description = val;
            },
          ),
          // TextFormField(
          //   decoration: InputDecoration(
          //       border: OutlineInputBorder(
          //           borderRadius: new BorderRadius.circular(10.0)),
          //       labelText: 'Restaurant Name'),
          //   onSaved: (val) {
          //     menu.restaurantName = ;
          //   },
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  this.menu.restaurantID =
                      FirebaseAuth.instance.currentUser.uid;
                  DatabaseMethods().postMenu(menu);
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('正在发布您的菜单...')));
                  Future.delayed(Duration(seconds: 1), () {
                    // 5s over, navigate to a new page
                    Navigator.pop(context);
                  });
                }
              },
              child: Text(AppLocalizations.of(context).text('submit_text')),
            ),
          ),
        ],
      ),
    );
  }

  Widget pictureCap() {
    return SizedBox(
      height: 100,
      width: 100,
      child: Icon(Icons.camera_alt),
    );
  }
}

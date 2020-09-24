import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Dukeats/providers/userLogin.dart';
import 'package:provider/provider.dart';

class RestaurantView extends StatefulWidget {
  @override
  _RestaurantViewState createState() => _RestaurantViewState();
}

class _RestaurantViewState extends State<RestaurantView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: restaurantsList(),
    ));
  }

  Widget billboard(Menu menu) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 200,
      child: Column(
        children: <Widget>[
          Container(
            //TODO:add Chinese
            child: Text(
              "Next Task:",
              style: TextStyle(fontSize: 30),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      child: Text('Menu Name: ${menu.menuName}'),
                    ),
                    Container(
                      child: Text('Menu Description: ${menu.description}'),
                    ),
                    Container(
                      child: Text('Menu Price: ${menu.price}'),
                    ),
                  ],
                ),
                Spacer(
                  flex: 1,
                ),
                Container(
                  child: RaisedButton(
                    child: Text('Finished'),
                    color: Colors.green,
                    onPressed: () {},
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget restaurantsList() {
    return FutureBuilder(
      future:
          DatabaseMethods().getAllMenu(FirebaseAuth.instance.currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data != null) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Menu curr = snapshot.data[index];
                return index == 0
                    ? billboard(curr)
                    : Container(
                        width: double.infinity,
                        color: Colors.black12,
                        child: Center(
                          child: ListTile(
                            title: Text(curr.menuName,style: TextStyle(color: Colors.black45),),
                            subtitle: Text(curr.description, style: TextStyle(color: Colors.black38),),
                          ),
                        ),
                      );
              });
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}

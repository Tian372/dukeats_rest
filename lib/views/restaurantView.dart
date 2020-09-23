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

  Widget restaurantsList() {
    // Future<List<String>> myTypedFuture() async {
    //   await Future.delayed(Duration(seconds: 2));
    //   List<String> list =
    //       new List<String>.generate(8, (index) => '${AppLocalizations.of(context).text("task_text")} $index');
    //
    //   return list;
    // }

    return FutureBuilder(
      future:
          DatabaseMethods().getAllMenu(FirebaseAuth.instance.currentUser.uid),
      builder: (context, snapshot) {
        print(snapshot);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data != null) {
          return ListView.separated(
              // ignore: missing_return
              separatorBuilder: (context, index) => Divider(
                    color: Colors.black26,
                    thickness: 1,
                  ),
              itemCount: snapshot.data.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Menu curr = snapshot.data[index];
                return Container(
                  height: 100,
                  width: double.infinity,
                  child: Center(
                    child: ListTile(
                      title: Text(curr.description),
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

import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  Widget billboard(DailyMenu dailyMenu) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 200,
      child: Column(
        children: <Widget>[
          Container(
            //TODO:add Chinese
            child: Text(
              "Next Delivery:",
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
                      child:imageGetter(dailyMenu.menu.imageName),
                    ),
                    Container(
                      child: Text('Menu Name: ${dailyMenu.menu.menuName}'),
                    ),
                    Container(
                      child: Text(
                          'Location: ${dailyMenu.locations.toString()}'),
                    ),
                    Container(
                      child: Text('Time: ${dailyMenu.pickupTimes.toString()}'),
                    ),
                    Container(
                      child: Text(
                          '${dailyMenu.orderNum} / ${dailyMenu.orderLimit}'),
                    )
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

  Widget laterTask(DailyMenu dailyMenu) {
    return Container(
        width: double.infinity,
        color: Colors.black12,
        child: Center(
          child: ListTile(
            leading: imageGetter(dailyMenu.menu.imageName),
            title: Text(dailyMenu.menu.menuName,
                style: TextStyle(color: Colors.black45)),
            subtitle: Text('${dailyMenu.orderNum} / ${dailyMenu.orderLimit}',
                style: TextStyle(color: Colors.black38)),
          ),
        ));
  }

  Widget restaurantsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: DatabaseMethods()
          .dailyMenuStream(FirebaseAuth.instance.currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.data != null) {
          return ListView.builder(
              itemCount: snapshot.data.docs.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                DailyMenu curr =
                DailyMenu.fromJson(snapshot.data.docs[index].data());
                curr.taskID = snapshot.data.docs[index].id;
                return index == 0 ? billboard(curr) : laterTask(curr);
              });
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget imageGetter(String imageName) {
    return FutureBuilder(
      future: DatabaseMethods().loadImage(imageName),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.done)
          return Container(
            height: 40,
            width: 40,
            child: Image.network(snapshot.data.toString()),
          );

        if (snapshot.connectionState ==
            ConnectionState.waiting)
          return Container(
              height: 40,
              width: 40,
              child: CircularProgressIndicator());

        return Container();
      },
    );
  }
}

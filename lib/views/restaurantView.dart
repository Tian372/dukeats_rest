import 'dart:math';

import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RestaurantView extends StatefulWidget {
  @override
  _RestaurantViewState createState() => _RestaurantViewState();
}

class _RestaurantViewState extends State<RestaurantView> {
  DailyMenu _dailyMenu;
  bool isHere = false;

  @override
  void initState() {
    super.initState();
    getDailyMenu();
  }

  Future<void> getDailyMenu() async {
    await DatabaseMethods().dailyMenuFuture().then((value) {
      setState(() {
        this._dailyMenu = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          height: 300,
          child: topMenuInfo(),
        ),
        this._dailyMenu == null
            ? Container()
            : Flexible(child: track(this._dailyMenu.dailyMenuID)),
      ],
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
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check_box,
                      ),
                      color: Colors.green,
                      tooltip: 'On Time',
                      onPressed: this.isHere
                          ? null
                          : () {
                              Scaffold.of(context).showSnackBar(SnackBar(
                                  duration: const Duration(seconds: 2),
                                  content: Text(
                                      'Customers are notified you are on your way!')));
                            },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.more_time,
                      ),
                      color: Colors.green,
                      tooltip: 'Need more time',
                      onPressed: this.isHere
                          ? null
                          : () {
                              _showAddTimeDialog(this.context);
                            },
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Container(
                      child: imageGetter(dailyMenu.menu.imageName),
                    ),
                    Container(
                      child: Text('Menu Name: ${dailyMenu.menu.menuName}'),
                    ),
                    Container(
                      child: Text('Location: ${dailyMenu.toString()}'),
                    ),
                    Container(
                      child: Text('Time: ${dailyMenu.toString()}'),
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
                  child: Column(
                    children: [
                      RaisedButton(
                        child: this.isHere
                            ? Text('Finished, next!')
                            : Text('I am Here'),
                        color: this.isHere ? Colors.orange : Colors.green,
                        onPressed: () {
                          if (this.isHere) {
                          } else {
                            if (!isHere) {
                              setState(() {
                                this.isHere = true;
                              });
                            } else {
                              DatabaseMethods()
                                  .deliveredByID(dailyMenu.dailyMenuID);
                              this.isHere = false;
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
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

  Widget topMenuInfo() {
    return this._dailyMenu == null
        ? Center(child: CircularProgressIndicator())
        : Container(
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 10,
              child: Column(
                children: [
                  imageGetter(this._dailyMenu.menu.imageName),
                  ListTile(
                    leading: Icon(Icons.arrow_forward_ios),
                    title: Text(this._dailyMenu.menu.menuName),
                    subtitle: Text(
                      '\$ ${this._dailyMenu.menu.price}',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                    child: Text(
                      this._dailyMenu.menu.description,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget imageGetter(String imageName) {
    return FutureBuilder(
      future: DatabaseMethods().loadImage(imageName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Image.network(snapshot.data.toString()),
          );

        if (snapshot.connectionState == ConnectionState.waiting)
          return Container(
              height: 40, width: 40, child: CircularProgressIndicator());

        return Container();
      },
    );
  }

  Future<int> _showAddTimeDialog(BuildContext bc) async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextEditingController textEditingController =
            new TextEditingController();
        return AlertDialog(
          //TODO: add chinese
          title: Text('How much more time do you need'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                //TODO: add chinese
                mealText('Time (int for now)', textEditingController),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).text('back_text')),
              onPressed: () {
                Navigator.of(context).pop(0);
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).text('submit_text')),
              onPressed: () {
                Navigator.of(context)
                    .pop(int.parse(textEditingController.text));
                Scaffold.of(bc).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                        '${int.parse(textEditingController.text.toString())} second added')));
              },
            ),
          ],
        );
      },
    );
  }

  Widget track(String dailyMenuID) {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseMethods().getPickUpByDailyMenuID(dailyMenuID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Pickups> list = [];
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              Pickups ps = Pickups.fromJson(snapshot.data.docs[i].data());
              ps.pickupID = snapshot.data.docs[i].id;
              list.add(ps);
              print(ps.location);
            }
            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: list.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return trackerTile(list[index]);
                });
          } else {
            return CircularProgressIndicator();
          }
        });
  }

  Widget trackerTile(Pickups pickups) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.trip_origin,
              color: Colors.blue,
            ),
            title: Text('${pickups.location}'),
            subtitle: Text(
              'Status: ${statusToNormalString(pickups.pickupStatus)}',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            trailing: Text(
              '${pickups.time.hour} : ${pickups.time.minute}',
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: () {
                  // Perform some action
                },
                child: const Text('On Time'),
              ),
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: () {
                  // Perform some action
                },
                child: const Text('Late'),
              ),
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: () {
                  // Perform some action
                },
                child: const Text('I am here!'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget mealText(String title, TextEditingController textEditingController) {
    return TextFormField(
//      controller: emailEditingController,
//      validator: (val) {
//        return RegExp(
//                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                .hasMatch(val)
//            ? null
//            : "Enter correct email";
//      },
      controller: textEditingController,
      decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: new BorderRadius.circular(10.0)),
          labelText: title),
    );
  }
}

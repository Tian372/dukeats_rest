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
  bool isHere = false;

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
                                  content: Text('Customers are notified you are on your way!')));
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
                      child:
                          Text('Location: ${dailyMenu.toString()}'),
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
                              DatabaseMethods().deliveredByID(dailyMenu.dailyMenuID);
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
          List<DailyMenu> dailyMenuList = new List<DailyMenu>();
          for (int i = 0; i < snapshot.data.docs.length; i++) {
            DailyMenu curr = DailyMenu.fromJson(snapshot.data.docs[i].data());
            curr.dailyMenuID = snapshot.data.docs[i].id;
            dailyMenuList.add(curr);
          }
          //dailyMenuList.sort((a, b) => a.pickupInfo..compareTo(b.pickupTimes));

          return ListView.builder(
              itemCount: dailyMenuList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (true) {
                  return index == 0
                      ? billboard(dailyMenuList[index])
                      : laterTask(dailyMenuList[index]);
                } else {
                  return Container();
                }
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
        if (snapshot.connectionState == ConnectionState.done)
          return Container(
            height: 50,
            width: 50,
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

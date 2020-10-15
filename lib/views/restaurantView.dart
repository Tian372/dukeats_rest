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
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          topMenuInfo(),
          this._dailyMenu == null
              ? Container()
              : Flexible(child: track(this._dailyMenu.dailyMenuID)),
        ],
      )),
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
      color: pickups.pickupStatus != Status.Finished ? Colors.white70: Colors.blueGrey,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.trip_origin,
              color: pickups.pickupStatus == Status.Finished
                  ? Colors.grey
                  : Colors.blue,
            ),
            title: Text('${pickups.location}'),
            subtitle: Text(
              'Status: ${statusToNormalString(pickups.pickupStatus)}',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            trailing: Text(
              '${pickups.time.hour} : ${pickups.time.minute}',
              style: TextStyle(fontSize: 20, color: Colors.black.withOpacity(0.8)),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: [
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: pickups.pickupStatus != Status.Arrived &&
                        pickups.pickupStatus != Status.Finished
                    ? () => _showOnTimeDialog(context, pickups.pickupID)
                    : null,
                child: const Text('On Time'),
              ),
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: pickups.pickupStatus == Status.Late ||
                        pickups.pickupStatus == Status.OnTime
                    ? () => _showAddTimeDialog(context, pickups.pickupID)
                    : null,
                child: const Text('Late'),
              ),
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: pickups.pickupStatus == Status.Late ||
                        pickups.pickupStatus == Status.OnTime
                    ? () => _showArrivalDialog(context, pickups.pickupID)
                    : pickups.pickupStatus == Status.Finished
                        ? null
                        : () => _showFinishDialog(context, pickups.pickupID),
                child: pickups.pickupStatus == Status.Finished ||
                        pickups.pickupStatus == Status.Arrived
                    ? Text('Finshed')
                    : Text('I am here!'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget topMenuInfo() {
    return this._dailyMenu == null
        ? Center(child: CircularProgressIndicator())
        : Container(
            padding: EdgeInsets.all(10),
            height: 300,
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
                    child: Text('Amount: ${this._dailyMenu.orderNum} / ${this._dailyMenu.orderLimit} ',
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

  Future _showAddTimeDialog(BuildContext bc, String pickupId) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextEditingController textEditingController =
            new TextEditingController();
        return AlertDialog(
          //TODO: add chinese
          title: Text('How much time do you need?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                //TODO: add chinese
                mealText('Time in Minutes', textEditingController)
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).text('back_text')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).text('submit_text')),
              onPressed: () {
                //TODO: add exception
                DatabaseMethods().lateTimeUpdate(this._dailyMenu.dailyMenuID,
                    pickupId, int.parse(textEditingController.text.toString()));
                Navigator.of(context).pop();
                Scaffold.of(bc).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                        '${int.parse(textEditingController.text.toString())} minutes added')));
              },
            ),
          ],
        );
      },
    );
  }

  Future _showOnTimeDialog(BuildContext bc, String pickupId) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //TODO: add chinese
          title: Text('You are going to arrive on time.'),
          content: Text('This will notify all the users.'),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).text('back_text')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).text('submit_text')),
              onPressed: () {
                //TODO: add exception
                DatabaseMethods()
                    .onTimeUpdate(this._dailyMenu.dailyMenuID, pickupId);
                Navigator.of(context).pop();
                Scaffold.of(bc).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text('Notified')));
              },
            ),
          ],
        );
      },
    );
  }

  Future _showArrivalDialog(BuildContext bc, String pickupId) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //TODO: add chinese
          title: Text('Are you that the pickup location'),
          content: Text('This will notify all the users.'),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).text('back_text')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).text('submit_text')),
              onPressed: () {
                //TODO: add exception
                DatabaseMethods()
                    .arrivalUpdate(this._dailyMenu.dailyMenuID, pickupId);
                Navigator.of(context).pop();
                Scaffold.of(bc).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text('Notified')));
              },
            ),
          ],
        );
      },
    );
  }

  Future _showFinishDialog(BuildContext bc, String pickupId) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          //TODO: add chinese
          title: Text('Are you that the pickup location'),
          content: Text('This will notify all the users.'),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).text('back_text')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).text('submit_text')),
              onPressed: () {
                //TODO: add exception
                DatabaseMethods()
                    .finishUpdate(this._dailyMenu.dailyMenuID, pickupId);
                Navigator.of(context).pop();
                Scaffold.of(bc).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text('Finished')));
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

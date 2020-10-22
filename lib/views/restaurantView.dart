import 'dart:math';
import 'dart:ui';

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
  int _stopLeft = 0;
  Stream dailyMenuStream;

  @override
  void initState() {
    super.initState();
    dailyMenuStream = DatabaseMethods().dailyMenuStream();
    getDailyMenu();
  }

  Future<void> getDailyMenu() async {
    await DatabaseMethods().dailyMenuFuture().then((value) {
      setState(() {
        this._dailyMenu = value;
      });
    });
  }

  Future<void> updateAmount() async {
    await DatabaseMethods().dailyMenuFuture().then((value) {
      setState(() {
        this._dailyMenu.orderNum = value.orderNum;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    dailyMenuStream.drain();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => getDailyMenu(),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: this._dailyMenu == null
                  ? Text('')
                  : Text(this._dailyMenu.menu.menuName),
              floating: true,
              pinned: true,
              snap: false,
              flexibleSpace: this._dailyMenu == null
                  ? Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        imageGetter(this._dailyMenu.menu.imageName),
                        Center(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10.0,
                                sigmaY: 10.0,
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                width: 200.0,
                                height: 200.0,
                                child: Text( this._dailyMenu.isFinished ? 'Finished ✅' :
                                  '\$ ${this._dailyMenu.menu.price}  Amount: ${this._dailyMenu.orderNum} / ${this._dailyMenu.orderLimit} ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              expandedHeight: 250,
            ),
            // Next, create a SliverList

            this._dailyMenu == null
                ? SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : track(this._dailyMenu.dailyMenuID),
          ],
        ),
      ),
    );
  }

  Widget track(String dailyMenuID) {
    return StreamBuilder<QuerySnapshot>(
        stream: DatabaseMethods().getPickUpByDailyMenuID(dailyMenuID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Pickups> list = [];
            int count = 0;
            for (int i = 0; i < snapshot.data.docs.length; i++) {
              Pickups ps = Pickups.fromJson(snapshot.data.docs[i].data());
              ps.pickupID = snapshot.data.docs[i].id;
              if (ps.pickupStatus != Status.Finished) {
                count++;
              }
              list.add(ps);
            }
            this._stopLeft = count;
            return SliverList(
                delegate: SliverChildBuilderDelegate(
              (context, index) => trackerTile(list[index]),
              childCount: list.length,
            ));
          } else {
            return SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            );
          }
        });
  }

  Widget trackerTile(Pickups pickups) {
    return Card(
      color: pickups.pickupStatus != Status.Finished
          ? Colors.white70
          : Colors.blueGrey,
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
              '${AppLocalizations.of(context).text('status_text')}: ${statusToNormalString(pickups.pickupStatus, context)}',
              style: TextStyle(color: Colors.black.withOpacity(0.6)),
            ),
            trailing: Text(
              '${pickups.time.hour} : ${pickups.time.minute}',
              style:
                  TextStyle(fontSize: 20, color: Colors.black.withOpacity(0.8)),
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
                child: Text(
                    '${AppLocalizations.of(context).text('on_time_text')}'),
              ),
              FlatButton(
                textColor: const Color(0xFF6200EE),
                onPressed: pickups.pickupStatus == Status.Late ||
                        pickups.pickupStatus == Status.OnTime
                    ? () => _showAddTimeDialog(context, pickups.pickupID)
                    : null,
                child:
                    Text('${AppLocalizations.of(context).text('late_text')}'),
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
                      ? Text(
                          '${AppLocalizations.of(context).text('finished_text')}')
                      : Text(
                          '${AppLocalizations.of(context).text('arrived_text')}')),
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
                    child: Text(
                      'Amount: ${this._dailyMenu.orderNum} / ${this._dailyMenu.orderLimit} ',
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
            child: Image.network(
              snapshot.data.toString(),
              fit: BoxFit.cover,
            ),
          );

        if (snapshot.connectionState == ConnectionState.waiting)
          return Container(
              height: 40,
              width: 40,
              child: Center(child: CircularProgressIndicator()));

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
          title: Text(AppLocalizations.of(context).text('add_time_text')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                //TODO: add chinese
                addTimeTextBox(
                    AppLocalizations.of(context).text('time_in_minutes'),
                    textEditingController)
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
          title: Text(AppLocalizations.of(context).text('on_time_line1')),
          content: Text(AppLocalizations.of(context).text('will_notify_text')),
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
                DatabaseMethods()
                    .onTimeUpdate(this._dailyMenu.dailyMenuID, pickupId);
                Navigator.of(context).pop();
                Scaffold.of(bc).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                        AppLocalizations.of(context).text('notified_text'))));
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
          title: Text(AppLocalizations.of(context).text('arrival_line1')),
          content: Text(AppLocalizations.of(context).text('will_notify_text')),
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
                DatabaseMethods()
                    .arrivalUpdate(this._dailyMenu.dailyMenuID, pickupId);
                Navigator.of(context).pop();
                Scaffold.of(bc).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                        AppLocalizations.of(context).text('notified_text'))));
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
          title: Text(AppLocalizations.of(context).text('finished_line1')),
          //content: Text('you cannot come back.'),
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
                DatabaseMethods()
                    .finishUpdate(this._dailyMenu.dailyMenuID, pickupId);
                this._stopLeft--;
                if (this._stopLeft == 0) {
                  DatabaseMethods()
                      .terminateTaskById(this._dailyMenu.dailyMenuID);
                }
                Navigator.of(context).pop();
                Scaffold.of(bc).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                        AppLocalizations.of(context).text('finished_text'))));
              },
            ),
          ],
        );
      },
    );
  }

  Widget addTimeTextBox(
      String title, TextEditingController textEditingController) {
    return TextFormField(
      validator: (val) {
        return RegExp(r"^([+]?[0-9]\d*|0)$").hasMatch(val)
            ? null
            : "Enter correct time";
      },
      keyboardType: TextInputType.number,
      controller: textEditingController,
      decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: new BorderRadius.circular(10.0)),
          labelText: title),
    );
  }
}

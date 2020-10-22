import 'dart:math';

import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/services/database.dart';
import 'package:Dukeats/views/individualOrderDetailView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PastOrderDetailView extends StatefulWidget {
  const PastOrderDetailView({
    Key key,
    this.deliveryTask,
  }) : super(key: key);

  final DailyMenu deliveryTask;

  @override
  State<StatefulWidget> createState() => _PastOrderDetailViewState();
}

class _PastOrderDetailViewState extends State<PastOrderDetailView> {
  List<Pickups> _pickupList;

  @override
  void initState() {
    super.initState();
    getPastTask();
  }

  Future<void> getPastTask() async {
    List<Pickups> temp = await DatabaseMethods()
        .getDetailByTaskId(widget.deliveryTask.dailyMenuID);
    setState(() {
      this._pickupList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title:
                Text(AppLocalizations.of(context).text('order_detail_text'))),
        body: SafeArea(
            child: this._pickupList == null
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(children: <Widget>[
                    ListTile(
                        title: Text(
                            AppLocalizations.of(context).text('order_id_text') +
                                ": "),
                        trailing: Text(widget.deliveryTask.dailyMenuID)),
                    ListTile(
                        title: Text(AppLocalizations.of(context)
                                .text('order_date_text') +
                            ": "),
                        trailing: Text(DateFormat('yyyy-MM-dd')
                            .format(widget.deliveryTask.postDate))),
                    ListTile(
                        title: Text(AppLocalizations.of(context)
                                .text('order_limit_text') +
                            ": "),
                        trailing:
                            Text(widget.deliveryTask.orderLimit.toString())),
                    ListTile(
                        title: Text(AppLocalizations.of(context)
                                .text('order_quantity_text') +
                            ": "),
                        trailing:
                            Text(widget.deliveryTask.orderNum.toString())),
                    ListTile(
                      title: Text("Pickup Location detail: "),
                    ),
                    for (final pickup in this._pickupList)
                      Card(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            IndividualOrderDetailView(orderIdList: pickup.orderIDs)));
                              },
                              child: ListTile(
                                title: Text(pickup.location),
                                subtitle: Text("Amount: " + pickup.orderIDs.length.toString()),
                                trailing: Text(pickup.pickupStatus.toString()),
                              )))
                    //OrderDetailByLocation(pickupsId: widget.deliveryTask.dailyMenuID)
                  ]))));
  }
}

/*
Container(
alignment: Alignment.center,
child: FutureBuilder(
future: DatabaseMethods()
    .loadImage(widget.deliveryTask.menu.imageName),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.done)
return Stack(children: <Widget>[
Opacity(
opacity: 0.4,
child: Container(
alignment: Alignment.center,
child: Image.network(snapshot.data.toString()),
)),
Center(
child: Text(
'Show text here',
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
fontSize: 22.0),
)),
]);
return CircularProgressIndicator();
},
),
),
*/

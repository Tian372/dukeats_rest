import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/services/database.dart';
import 'package:flutter/material.dart';

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
        child: Column(
      children: [
        Container(
          height: 300,
          child: topMenuInfo(),
        ),
        Flexible(child: track()),
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
    return FutureBuilder<DailyMenu>(
      future: DatabaseMethods().dailyMenuFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return Container(
            child: Card(
              clipBehavior: Clip.antiAlias,
              elevation: 10,
              child: Column(
                children: [
                  imageGetter(snapshot.data.menu.imageName),
                  ListTile(
                    leading: Icon(Icons.arrow_forward_ios),
                    title: Text(snapshot.data.menu.menuName),
                    subtitle: Text(
                      '\$ ${snapshot.data.menu.price}',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                    child: Text(
                      snapshot.data.menu.description,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
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

  Widget track() {
    return Container(
      margin: EdgeInsets.all(8.0),
      height: 100.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Icon(
                  Icons.trip_origin,
                  color: Colors.blue,
                ),
              ),
              Icon(Icons.fiber_manual_record, color: Colors.grey, size: 12),
              Icon(Icons.fiber_manual_record, color: Colors.grey, size: 12),
              Icon(Icons.fiber_manual_record, color: Colors.grey, size: 12),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Icon(
                  Icons.location_on,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 40.0,
                  color: Colors.grey,
                  child: Center(
                    child: Text("Your widget here"),
                  ),
                ),
                Container(
                  height: 40.0,
                  margin: EdgeInsets.only(top: 4.0),
                  color: Colors.greenAccent,
                  child: Center(
                    child: Text("Your widget here"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget trackTile(){

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

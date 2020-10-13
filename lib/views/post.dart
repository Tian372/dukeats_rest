import 'dart:collection';

import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).text('post_today_text')),
        ),
        body: SafeArea(child: MealForm()));
  }
}

class MealForm extends StatefulWidget {
  @override
  MealFormState createState() {
    return MealFormState();
  }
}

class MealFormState extends State<MealForm> {
  final _formKey = GlobalKey<FormState>();
  int _amount = 0;
  String _selectedID;
  int _selectedIndex = -1;
  List<Menu> _allMenus;

  // //TODO: need to change to currect time format
  List<Pickups> pickupData = [];

  @override
  void initState() {
    super.initState();
    getMenus();
  }

  Future<void> getMenus() async {
    List<Menu> temp = await DatabaseMethods().getAllMenu();
    setState(() {
      this._allMenus = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(width: double.infinity, height: 150, child: menuList()),
          amount(),
          location(),
          Container(width: double.infinity, height: 70, child: locationList()),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: RaisedButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  DailyMenu dailyMenu = new DailyMenu(
                    menu: this._allMenus[this._selectedIndex],
                    orderLimit: this._amount,
                    orderNum: 0,
                    restaurantID: FirebaseAuth.instance.currentUser.uid,
                    pickupInfo: this.pickupData,
                  );
                  //TODo: add translation
                  Scaffold.of(context)
                      .showSnackBar(SnackBar(content: Text('正在发布您的菜单...')));
                  DatabaseMethods().saveDailyMenu(dailyMenu);
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

  Widget amount() {
    return RaisedButton(
      onPressed: () {
        _showAmountDialog().then((value) {
          setState(() {
            _amount = value;
          });
        });
      },
      child:
          Text('${AppLocalizations.of(context).text('amount_text')}: $_amount'),
    );
  }

  Widget location() {
    return RaisedButton(
      onPressed: () {
        _showAddLocation().then((value) {
          setState(() {
            if (value != null) {
              this.pickupData.add(value);
            }
          });
        });
      },
      child: Text('Add a location'),
    );
  }

  Future<int> _showAmountDialog() async {
    return showDialog<int>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextEditingController textEditingController =
            new TextEditingController();
        return AlertDialog(
          title: Text(AppLocalizations.of(context).text('amount_text')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${AppLocalizations.of(context).text('amount_text')}'),
                mealText('${AppLocalizations.of(context).text('amount_text')}',
                    textEditingController),
                Text(
                    '${AppLocalizations.of(context).text('amount_help_text')}'),
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
              },
            ),
          ],
        );
      },
    );
  }

  Future<Pickups> _showAddLocation() async {
    return showDialog<Pickups>(
      context: context,
      builder: (BuildContext context) {
        TextEditingController locationTextController =
            new TextEditingController();
        // TextEditingController timeController = new TextEditingController();
        DateTime _selectedTime;
        return AlertDialog(
          //TODO: translation
          title: Text('Add a new pick-up location and time'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Location:'),
                mealText('location', locationTextController),
                Text('Time (int for now):'),
                // mealText('Time', timeController),
                FlatButton(
                    child: Text('Time Picker Test'),
                    onPressed: () {
                      showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.fromDateTime(new DateTime.now()))
                          .then((value) {
                        final now = new DateTime.now();
                        _selectedTime = new DateTime(now.year, now.month,
                            now.day, value.hour, value.minute);
                      });
                    })
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).text('back_text')),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).text('submit_text')),
              onPressed: () {
                Pickups data = new Pickups(
                    '',
                    locationTextController.text.toString(),
                    _selectedTime,
                    Status.OnTime,
                    null);
                Navigator.of(context).pop(data);
              },
            ),
          ],
        );
      },
    );
  }

  Widget menuList() {
    return this._allMenus == null
        ? Container()
        : ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: this._allMenus.length,
            shrinkWrap: false,
            itemBuilder: (context, index) {
              Menu menu = this._allMenus[index];
              return Card(
                color: index == this._selectedIndex
                    ? Colors.blue
                    : Colors.transparent,
                child: InkWell(
                  splashColor: Colors.blue.withAlpha(30),
                  onTap: () {
                    setState(() {
                      this._selectedIndex = index;
                      this._selectedID = menu.menuID;
                    });
                    print('Card $index tapped');
                  },
                  child: Container(
                    width: 80,
                    height: 70,
                    child: Column(
                      children: [
                        imageGetter(menu.imageName),
                        Text(menu.menuName),
                        Text('\$ ${menu.price}'),
                        Text(
                          menu.menuID,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  ),
                ),
              );
            });
  }

  Widget locationList() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: this.pickupData.length,
        shrinkWrap: false,
        itemBuilder: (context, index) {
          return Card(
            child: Container(
              height: 50,
              child: Column(
                children: [
                  Text(this.pickupData[index].location),
                  Text(
                    this.pickupData[index].time.toString(),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          );
        });
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

  Widget imageGetter(String imageName) {
    return FutureBuilder(
      future: DatabaseMethods().loadImage(imageName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done)
          return Container(
            height: 40,
            width: 40,
            child: Image.network(snapshot.data.toString()),
          );

        if (snapshot.connectionState == ConnectionState.waiting)
          return Container(
              height: 40, width: 40, child: CircularProgressIndicator());

        return Container();
      },
    );
  }
}

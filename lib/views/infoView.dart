import 'package:flutter/material.dart';

class InfoView extends StatefulWidget {
  @override
  _InfoViewState createState() => _InfoViewState();
}

class _InfoViewState extends State<InfoView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      child: restaurantInfo(),
    ));
  }

  Widget restaurantInfo() {
    Future<Map<String, String>> myTypedFuture() async {
      await Future.delayed(Duration(seconds: 1));
      var restaurant = new Map<String, String>();
      restaurant['name'] = 'cool restaurant';
      restaurant['number'] = '12345678';
      restaurant['address'] = 'My address, NC, 27705';
      restaurant['sell'] = '3000';
      return restaurant;
    }

    return FutureBuilder(
      future: myTypedFuture(),
      builder: (context, snapshot) {
        var restaurant = new Map<String, String>();
        if (snapshot.hasData) {
          restaurant = snapshot.data;
        }
        return snapshot.hasData
            ? Center(
                child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(20),
                childAspectRatio: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 1,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(child: Text('Name: ${restaurant['name']}')),
                    color: Colors.teal[100],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child:
                        Center(child: Text('Phone: ${restaurant['number']}')),
                    color: Colors.teal[200],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                        child: Text('Address: ${restaurant['address']}')),
                    color: Colors.teal[300],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Center(child: Text('Sells: ${restaurant['sell']}')),
                    color: Colors.teal[400],
                  ),
                ],
              ))
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

import 'package:Dukeats/services/database.dart';
import 'package:flutter/material.dart';
import 'package:Dukeats/localization/localization.dart';
import 'package:Dukeats/views/post.dart';
import 'package:Dukeats/models/order.dart';
import 'package:Dukeats/providers/userLogin.dart';
import 'package:provider/provider.dart';

class OrderHistoryView extends StatefulWidget {
  @override
  _OrderHistoryViewState createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  int currentSegment = 0;
  List<Order> _pastOrderList;

  @override
  void initState() {
    super.initState();
    getPastOrder();
  }

  void onValueChanged(int newValue) {
    setState(() {
      currentSegment = newValue;
    });
  }

  Future<void> getPastOrder() async {
    List<Order> temp = await DatabaseMethods().getPastOrder();
    setState(() {
      this._pastOrderList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AppLocalizations.of(context).text('past_order_text'),
      AppLocalizations.of(context).text('current_order_text'),
    ];

    return this._pastOrderList == null
        ? Center(child: CircularProgressIndicator())
        : DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              appBar: AppBar(
                //automaticallyImplyLeading: false,
                title: TabBar(
                  isScrollable: false,
                  tabs: [
                    for (final tab in tabs) Tab(text: tab),
                  ],
                ),
              ),
              body: Scrollbar(
                child: ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    for (final order in _pastOrderList)
                      OrderGroupCard(order: order)
                  ],
                ),
              ),
            ),
          );
  }
}

class OrderGroupCard extends StatefulWidget {
  const OrderGroupCard({
    Key key,
    this.order,
  }) : super(key: key);

  final Order order;

  @override
  State<StatefulWidget> createState() => _OrderGroupCardState();
}

class _OrderGroupCardState extends State<OrderGroupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (BuildContext context) => Post()));
        },
        child: Container(
          width: 300,
          height: 100,
          child: Text('A card that can be tapped' +
              widget.order.clientEmail.toString()),
        ),
      ),
    );
  }
}

// Future<List<String>> myTypedFuture() async {
//   await Future.delayed(Duration(seconds: 2));
//   List<String> list = new List<String>();
//   for (int i = 0; i < 10; i++) {
//     list.add('Order History: ' + i.toString());
//   }
//   return list;
// }

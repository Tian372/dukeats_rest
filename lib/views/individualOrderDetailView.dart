import 'package:Dukeats/models/order.dart';
import 'package:Dukeats/services/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IndividualOrderDetailView extends StatefulWidget {
  const IndividualOrderDetailView({
    Key key,
    this.orderIdList,
  }) : super(key: key);

  final orderIdList;

  @override
  State<StatefulWidget> createState() => _IndividualOrderDetailViewState();
}

class _IndividualOrderDetailViewState extends State<IndividualOrderDetailView> {
  List<Order> _orderList;

  @override
  void initState() {
    super.initState();
    getAllOrder();
  }

  Future<void> getAllOrder() async {
    List<Order> temp =
        await DatabaseMethods().getOrderListById(widget.orderIdList);
    setState(() {
      this._orderList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: this._orderList == null
          ? Center(child: CircularProgressIndicator())
          : ListView(children: [
              ListTile(
                title: Text("User"),
                trailing: Text("Amount"),
              ),
              for (final order in this._orderList)
                Card(
                    child: ListTile(
                  title: Text(order.userEmail),
                  subtitle: Text(order.pickupId),
                  trailing: Text(order.amount.toString()),
                ))
            ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:Dukeats/providers/userLogin.dart';
import 'package:provider/provider.dart';

class OrderHistoryView extends StatefulWidget {
  @override
  _OrderHistoryViewState createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLogin = Provider.of<UserLogin>(context);
    return SafeArea(
        child: Center(
          child: Text('OrderHistory'),
        ));
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
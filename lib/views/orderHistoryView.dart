import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/services/database.dart';
import 'package:Dukeats/views/pastOrderDetailView.dart';
import 'package:flutter/material.dart';
import 'package:Dukeats/localization/localization.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:Dukeats/providers/userLogin.dart';
import 'package:provider/provider.dart';

class OrderHistoryView extends StatefulWidget {
  @override
  _OrderHistoryViewState createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView> {
  int _currentSegment = 0;
  List<DailyMenu> _pastTaskList;

  @override
  void initState() {
    super.initState();
    getPastTask();
  }

  void onValueChanged(int newValue) {
    setState(() {
      _currentSegment = newValue;
    });
  }

  Future<void> getPastTask() async {
    List<DailyMenu> temp = await DatabaseMethods()
        .getAllTask(FirebaseAuth.instance.currentUser.uid);
    setState(() {
      this._pastTaskList = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      AppLocalizations.of(context).text('past_order_text'),
      //AppLocalizations.of(context).text('current_order_text'),
    ];

    return this._pastTaskList == null
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
              body: TabBarView(
                children: [
                  for (final tab in tabs) TaskList(taskList: _pastTaskList)
                ],
              ),
            ),
          );
  }
}

class TaskList extends StatefulWidget {
  const TaskList({
    Key key,
    this.taskList,
  }) : super(key: key);

  final List<DailyMenu> taskList;

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return GroupedListView<DailyMenu, String>(
        padding: const EdgeInsets.all(8),
        elements: widget.taskList,
        groupBy: (element) => DateFormat('yyyy-MM-dd').format(element.postDate),
        groupSeparatorBuilder: (String value) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
        itemComparator: (item1, item2) =>
            item1.postDate.compareTo(item2.postDate),
        order: GroupedListOrder.DESC,
        itemBuilder: (context, dynamic element) =>
            OrderGroupCard(deliveryTask: element));
  }
}

class OrderGroupCard extends StatefulWidget {
  const OrderGroupCard({
    Key key,
    this.deliveryTask,
  }) : super(key: key);

  final DailyMenu deliveryTask;

  @override
  State<StatefulWidget> createState() => _OrderGroupCardState();
}

class _OrderGroupCardState extends State<OrderGroupCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
              builder: (BuildContext context) => PastOrderDetailView(
                    deliveryTask: widget.deliveryTask,
                  )));
        },
        child: ListTile(
          title: Text(widget.deliveryTask.menu.menuName,
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(widget.deliveryTask.menu.menuName),
          trailing: Text("money"),
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

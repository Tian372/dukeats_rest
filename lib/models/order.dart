import 'package:cloud_firestore/cloud_firestore.dart';

class Order{
  String orderId;
  String userEmail;
  String dailyMenuId;
  String pickupId;
  int amount;

  Order({this.orderId, this.userEmail, this.dailyMenuId, this.pickupId, this.amount});


  factory Order.fromJson(Map<String, dynamic> json) => Order(
    userEmail: json['userEmail'] as String,
    dailyMenuId: json['dailyMenuID'] as String,
    pickupId: json['pickupID'] as String,
    amount: json['amount'] as int,
  );

}
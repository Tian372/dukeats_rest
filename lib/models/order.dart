import 'package:cloud_firestore/cloud_firestore.dart';

class Order{
  Map<String, int> cart;
  String clientEmail;
  String status;

  Order({this.cart, this.clientEmail, this.status});

/*
  factory Order.fromJson(Map<String, dynamic> json) => Order(
    cart: json['cart'] as Map<String, int>,
    clientEmail: json['clientEmail'] as String,
    status: json['status'] as String,
  );

 */
}
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DailyMenu {
  //TODO: change to correct time format
  Menu menu;
  DateTime postDate = new DateTime.now();
  int orderNum;
  int orderLimit;
  String restaurantID;
  List<Pickups> pickupInfo = new List();
  String dailyMenuID = ''; //read from firebase document id

  DailyMenu(
      {this.orderNum,
      this.orderLimit,
      this.restaurantID,
      this.menu,
      this.pickupInfo});

  Map<String, dynamic> toJson() => {
        'postDate': this.postDate.toUtc(),
        'orderNum': this.orderNum,
        'orderLimit': this.orderLimit,
        'restaurantID': this.restaurantID,
        'menuID': this.menu.menuID,
        'menuName': this.menu.menuName,
        'price': this.menu.price,
        'description': this.menu.description,
        'imageName': this.menu.imageName,
      };

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    DailyMenu jsonMenu = new DailyMenu();

    Timestamp timestamp = json['postDate'] as Timestamp;
    jsonMenu.postDate = timestamp.toDate();

    jsonMenu.orderLimit = json['orderLimit'] as int;
    jsonMenu.orderNum = json['orderNum'] as int;
    jsonMenu.restaurantID = json['restaurantID'] as String;

    jsonMenu.menu = new Menu(
        menuName: json['menuName'] as String,
        price: json['price'] as int,
        description: json['description'] as String,
        imageName: json['imageName'] as String);
    jsonMenu.menu.menuID = json['menuID'] as String;

    return jsonMenu;
  }
}

class Menu {
  String menuID = ''; //read from firebase doc id
  String menuName;
  int price;
  String description;
  String imageName;

  Menu({this.menuName, this.price, this.description, this.imageName});

  Map<String, dynamic> toJson() => {
        'menuName': this.menuName,
        'price': this.price,
        'description': this.description,
        'imageName': this.imageName,
      };

  Menu.fromJson(Map<String, dynamic> json)
      : menuName = json['menuName'] as String,
        price = json['price'] as int,
        description = json['description'] as String,
        imageName = json['imageName'] as String;
}

enum Status { OnTime, Late, Arrived, Finished }

String statusToString(Status status) {
  switch (status) {
    case Status.OnTime:
      return 'ONTM';
    case Status.Late:
      return 'LATE';
    case Status.Arrived:
      return 'ARRV';
    case Status.Finished:
      return 'FNSH';
    default:
      return '';
  }
}

Status stringToStatus(String str) {
  if (str == 'ONTM') {
    return Status.OnTime;
  }
  if (str == 'LATE') {
    return Status.Late;
  }
  if (str == 'ARRV') {
    return Status.Arrived;
  }
  if (str == 'FNSH') {
    return Status.Finished;
  }
  return Status.OnTime;
}

class Pickups {
  String pickupID = ''; //read from firebase doc id
  String location;
  DateTime time;
  Status pickupStatus;
  List<String> orderIDs;

  Pickups(
      {this.pickupID,
      this.location,
      this.time,
      this.pickupStatus,
      this.orderIDs});

  Map<String, dynamic> toJson() => {
        'location': this.location,
        'time': this.time.toUtc(),
        'status': statusToString(this.pickupStatus),
        'orderIDs': this.orderIDs,
      };

  factory Pickups.fromJson(Map<String, dynamic> json) {
    Pickups pickups = new Pickups();
    pickups.location = json['location'] as String;
    pickups.time = (json['time'] as Timestamp).toDate();
    pickups.pickupStatus = stringToStatus(json['status'] as String);
    pickups.orderIDs = (json["orderIDs"] as List<dynamic> ?? [])
        ?.map((e) => e as String)
        ?.toList();
    return pickups;
  }
}

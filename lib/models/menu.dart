import 'package:cloud_firestore/cloud_firestore.dart';

class DailyMenu {
  String menuID;
  String locations;

  //TODO: change to correct time format
  int pickupTimes;
  Menu menu;
  DateTime dateTime = new DateTime.now();
  int orderNum;
  int orderLimit;
  String restaurantID;
  String taskID = '';
  String imageName;
  bool delivered = false;

  DailyMenu(
      {this.menuID,
      this.locations,
      this.pickupTimes,
      this.orderNum,
      this.orderLimit,
      this.restaurantID,
      this.menu,});

  Map<String, dynamic> toJson() => {
        'menuID': this.menuID,
        'locations': this.locations,
        'pickupTimes': this.pickupTimes,
        'postDate': this.dateTime.toUtc(),
        'orderNum': this.orderNum,
        'orderLimit': this.orderLimit,
        'restaurantID': this.restaurantID,
        'menuName': this.menu.menuName,
        'price': this.menu.price,
        'description': this.menu.description,
        'imageName': this.menu.imageName,
        'delivered': this.delivered,
      };

  factory DailyMenu.fromJson(Map<String, dynamic> json) {
    DailyMenu jsonMenu = new DailyMenu();
    jsonMenu.menuID = json['menuID'] as String;
    // jsonMenu.locations = (json["locations"] as List<dynamic> ?? [])
    //     ?.map((e) => e as String)
    //     ?.toList();
    // jsonMenu.pickupTimes = (json["pickupTimes"] as List<dynamic> ?? [])
    //     ?.map((e) => e as String)
    //     ?.toList();
    jsonMenu.locations = json['locations'] as String;
    jsonMenu.pickupTimes = json['pickupTimes'] as int;
    Timestamp timestamp = json['postDate'] as Timestamp;
    jsonMenu.dateTime = timestamp.toDate();
    jsonMenu.orderLimit = json['orderLimit'] as int;
    jsonMenu.orderNum = json['orderNum'] as int;
    jsonMenu.restaurantID = json['restaurantID'] as String;
    jsonMenu.menu = new Menu(
        menuName: json['menuName'] as String,
        price: json['price'] as int,
        description: json['description'] as String,
        imageName: json['imageName'] as String);
    jsonMenu.delivered = json['delivered'] as bool;

    return jsonMenu;
  }
}

class Menu {
  String menuID = '';
  String menuName;
  int price;
  String description;
  String imageName;
  String restaurantID;

  Menu(
      {this.menuName,
      this.price,
      this.description,
      this.restaurantID,
      this.imageName});

  Map<String, dynamic> toJson() => {
        'menuName': this.menuName,
        'price': this.price,
        'description': this.description,
        'restaurantID': this.restaurantID,
        'imageName': this.imageName,
      };

  Menu.fromJson(Map<String, dynamic> json)
      : menuName = json['menuName'] as String,
        price = json['price'] as int,
        description = json['description'] as String,
        restaurantID = json['restaurantName'] as String,
        imageName = json['imageName'] as String;
}


class Post {
  String menuID;
  List<String> locations;
  List<DateTime> pickupTimes;
  DateTime dateTime = new DateTime.now();

  Post({this.menuID, this.locations, this.pickupTimes});

  Map<String, dynamic> toJson() => {
        'menuID': this.menuID,
        'locations': this.locations,
        'pickupTimes': this.pickupTimes,
        'postData': this.dateTime.toUtc().toString()
      };

  Post.fromJson(Map<String, dynamic> json)
      : menuID = json['menuID'] as String,
        locations = json['locations'] as List<String>,
        pickupTimes = json['pickupTimes'] as List<DateTime>,
        dateTime = json['postData'] as DateTime;
}

class Menu {
  String menuID = '';
  String menuName;
  int price;
  String description;
  String restaurantID;

  Menu({this.menuName, this.price, this.description, this.restaurantID});

  Map<String, dynamic> toJson() => {
        'menuName': this.menuName,
        'price': this.price,
        'description': this.description,
        'restaurantID': this.restaurantID
      };

  Menu.fromJson(Map<String, dynamic> json)
      : menuName = json['menuName'] as String,
        price = json['price'] as int,
        description = json['description'] as String,
        restaurantID = json['restaurantName'] as String;
}

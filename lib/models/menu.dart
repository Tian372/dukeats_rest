class Item {
  String name;
  String price;

  Item({this.name, this.price});
}

class Menu {
  String menuName;
  double price;
  String description;

  // List<String> items;
  String restaurantName;

  Menu({this.menuName, this.price, this.description, this.restaurantName});

  Map<String, dynamic> toJson() => {
        'menuName': this.menuName,
        'price': this.price,
        'description': this.description,
        // 'items': this.items,
        'restaurantName': this.restaurantName
      };

  Menu.fromJson(Map<String, dynamic> json)
      : menuName = json['menuName'] as String,
        price = json['price'] as double,
        description = json['description'] as String,
        // items = json['items'],
        restaurantName = json['restaurantName'] as String;
}

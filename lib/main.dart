import 'package:flutter/material.dart';
import 'package:Dukeats/providers/userLogin.dart';
import 'package:Dukeats/views/authView.dart';
import 'package:Dukeats/views/infoView.dart';
import 'package:Dukeats/views/postList.dart';
import 'package:Dukeats/views/restaurantView.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider<UserLogin>(
          create: (context) => UserLogin(), child: MainPage()),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  int _currentIndex = 0;
  List<Widget> _children = [
    RestaurantView(),
    PostList(),
    InfoView(),
  ];
  List<Widget> _title = [
    Text('Tasks'),
    Text('New Post'),
    Text('Restaurant Info'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLoginProvider = Provider.of<UserLogin>(context);
    return !userLoginProvider.loginStatus ? Authenticate() : navigation();
  }

  Widget navigation() {
    void onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: _title[_currentIndex],
      ),
      body: _children[_currentIndex], // new
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped, // new
        currentIndex: _currentIndex, // new
        items: [
          new BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text('Ongoing'),
          ),
          new BottomNavigationBarItem(
            icon: Icon(Icons.line_weight),
            title: Text('Post'),
          ),
          new BottomNavigationBarItem(
              icon: Icon(Icons.person), title: Text('Sell'))
        ],
      ),
    );
  }
}

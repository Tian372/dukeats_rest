import 'dart:io';

import 'package:Dukeats/models/menu.dart';
import 'package:Dukeats/models/order.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseMethods {
  Future<void> saveMenu(Menu menu) async {
    FirebaseFirestore.instance
        .collection("restaurants")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('menu')
        .add(menu.toJson())
        .catchError((e) {
      print(e.toString());
    });
  }

  Future saveDailyMenu(DailyMenu dailyMenu) async {
    FirebaseFirestore.instance
        .collection("dailyMenu")
        .add(dailyMenu.toJson())
        .then((docRef) {
      for (Pickups pickups in dailyMenu.pickupInfo) {
        docRef.collection('pickups').add(pickups.toJson());
      }
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future<List<Menu>> getAllMenu() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('restaurants')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('menu')
        .get()
        .catchError((e) {
      print(e.toString());
    });

    List<Menu> myList = [];
    for (int i = 0; i < qs.docs.length; i++) {
      Menu tmp = Menu.fromJson(qs.docs[i].data());
      tmp.menuID = qs.docs[i].id;
      myList.add(tmp);
    }
    return myList;
  }

  Future<List<DailyMenu>> getAllTask(String id) async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('dailyMenu')
        .where('restaurantID', isEqualTo: id)
        .get()
        .catchError((e) {
      print(e.toString());
    });

    List<DailyMenu> myList = new List(qs.docs.length);
    for (int i = 0; i < qs.docs.length; i++) {
      DailyMenu tmp = DailyMenu.fromJson(qs.docs[i].data());
      tmp.dailyMenuID = qs.docs[i].id;
      myList.add(tmp);
    }
    myList.sort((a, b) => b.postDate.compareTo(a.postDate));
    return myList;
  }

  Stream<QuerySnapshot> dailyMenuStream() {
    return FirebaseFirestore.instance
        .collection('restaurants')
        // .where('pickupTimes', isLessThan: 25)
        .where('restaurantID', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .limit(1)
        .snapshots();
  }

  Future<DailyMenu> dailyMenuFuture() async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('dailyMenu')
        .where('restaurantID', isEqualTo: FirebaseAuth.instance.currentUser.uid)
        .get()
        .catchError((e) {
      print(e.toString());
    });
    return DailyMenu.fromJson(qs.docs[0].data());
  }

  Future<Menu> getMenuById(String menuID) async {
    DocumentSnapshot qs = await FirebaseFirestore.instance
        .collection('menu')
        .doc(menuID)
        .get()
        .catchError((e) {
      print(e.toString());
    });

    Menu tmp = Menu.fromJson(qs.data());
    tmp.menuID = qs.id;
    return tmp;
  }

  Future uploadImageToFirebase(File imageFile, String fileName) async {
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('images/$fileName');
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    taskSnapshot.ref.getDownloadURL().then(
          (value) => print("Done: $value"),
        );
  }

  Future deliveredByID(String taskID) async {
    Firestore.instance.collection('dailyMenu').doc(taskID).update({
      'delivered': true,
    });
  }

  Future<dynamic> loadImage(String imageName) async {
    return await FirebaseStorage.instance
        .ref()
        .child('images/$imageName')
        .getDownloadURL();
  }

  Future<List<Order>> getPastOrder() async {
    List<Order> myList = [];
    myList.add(new Order());
    return await Future.delayed(Duration(milliseconds: 500), () => myList);
  }

}

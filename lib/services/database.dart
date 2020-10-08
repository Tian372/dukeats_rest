import 'dart:io';

import 'package:Dukeats/models/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class DatabaseMethods {
  Future<void> postMenu(Menu menu) async {
    FirebaseFirestore.instance
        .collection("menu")
        .add(menu.toJson())
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<void> postDailyMenu(DailyMenu dailyMenu) async {
    FirebaseFirestore.instance
        .collection("dailyMenu")
        .add(dailyMenu.toJson())
        .catchError((e) {
      print(e.toString());
    });
  }

  Future<List<Menu>> getAllMenu(String id) async {
    QuerySnapshot qs = await FirebaseFirestore.instance
        .collection('menu')
        .where('restaurantID', isEqualTo: id)
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
      tmp.taskID = qs.docs[i].id;
      myList.add(tmp);
    }
    myList.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return myList;
  }

  Stream<QuerySnapshot> dailyMenuStream(String id) {
    return FirebaseFirestore.instance
        .collection('dailyMenu')
        // .where('pickupTimes', isLessThan: 25)
        // .where('restaurantID', isEqualTo: id)
        .where('delivered', isEqualTo: false)
        .snapshots();
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
    Firestore.instance
        .collection('dailyMenu')
        .doc(taskID)
        .update({
      'delivered': true,
    });
  }
  Future<dynamic> loadImage(String imageName) async {
    return await FirebaseStorage.instance
        .ref()
        .child('images/$imageName')
        .getDownloadURL();
  }
}

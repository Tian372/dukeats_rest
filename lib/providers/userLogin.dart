import 'package:Dukeats/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserLogin with ChangeNotifier {

  bool loginStatus= false;
  User currentUser;
  AuthService as = new AuthService();

  Future<void> login() async {
    loginStatus = true;
    //currentUser = as.signInWithEmailAndPassword(email, password) as User;
    Future.delayed(Duration(seconds: 1), () {
      notifyListeners();
    });
  }

  void logout() {
    loginStatus = false;
    //something
    notifyListeners();
  }

}
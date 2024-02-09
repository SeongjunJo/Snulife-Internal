import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseStates extends ChangeNotifier {
  FirebaseStates() {
    init();
  }

  bool _loggedIn = false;

  bool get loggedIn => _loggedIn;

  void init() {
    FirebaseAuth.instance.userChanges().listen((User? user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}

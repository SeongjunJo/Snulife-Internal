import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../common_instances.dart';

class FirebaseStates extends ChangeNotifier {
  FirebaseStates() {
    _init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  bool _isManager = false;
  bool get isManager => _isManager;

  Future<void> _init() async {
    FirebaseAuth.instance.userChanges().listen((User? user) async {
      if (user != null) {
        _loggedIn = true;
        final userInfo = await firebaseInstance.db
            .collection('users')
            .doc(firebaseInstance.userId)
            .get();
        userInfo['position'].contains('대표')
            ? _isManager = true
            : _isManager = false;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}

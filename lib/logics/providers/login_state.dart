import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';

import '../firebase_options.dart';

class LogInState extends ChangeNotifier {
  LogInState() {
    init();
  }

  bool _isLoggedIn = false;
  late User? _user;

  bool get isLoggedIn => _isLoggedIn;

  User? get user => _user;

  Future<void> init() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    FirebaseUIAuth.configureProviders([
      EmailAuthProvider(),
    ]);

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _isLoggedIn = false;
        _user = null;
      } else {
        _isLoggedIn = true;
        _user = user;
      }
      notifyListeners();
    });
  }
}

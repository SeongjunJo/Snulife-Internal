import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum FirebaseAuthErrorTypes {
  invalidEmail,
  channelError,
  invalidCredential,
  userDisabled,
  networkRequestFailed,
  tooManyRequests,
  unknownError,
  none,
}

class FirebaseInstance {
  final _db = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;
  late final _userId = _user?.uid;
  late var userName = _user?.displayName;

  FirebaseFirestore get db => _db;
  User? get user => _user;
  String? get userId => _userId;
}

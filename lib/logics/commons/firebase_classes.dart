import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum FirebaseAuthErrorTypes {
  invalidEmail,
  channelError,
  invalidCredential,
  userDisabled,
  networkRequestFailed,
  unknownError,
  none,
}

class FirebaseInstance {
  final _db = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  FirebaseFirestore get db => _db;
  String? get userId => _userId;
}

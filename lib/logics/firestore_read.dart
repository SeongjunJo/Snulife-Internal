import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreReader {
  // make singleton class
  FirestoreReader._();
  static final FirestoreReader _instance = FirestoreReader._();
  factory FirestoreReader() => _instance;

  final _db = FirebaseFirestore.instance;
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, dynamic>> getUserInfo() async {
    final userInfoField = _db.collection('users').doc(_userId).get();
    Map<String, dynamic> userInfo = {};

    await userInfoField.then((DocumentSnapshot doc) {
      userInfo['name'] = doc['name'];
      userInfo['team'] = doc['team'];
      userInfo['isSenior'] = doc['isSenior'];
      userInfo['position'] = doc['position'];
    });

    return userInfo;
  }

  Future<String> getClerk() async {
    final clerkCollection = _db.collection('clerks').get();
    String clerk = '';

    await clerkCollection.then(
      (querySnapshot) {
        int leastCount = 100; // sufficiently large number
        for (var docSnapshot in querySnapshot.docs) {
          if (docSnapshot.data()['count'] < leastCount) {
            leastCount = docSnapshot.data()['count'];
            clerk = docSnapshot.id;
          }
        }
      },
    );
    return clerk;
  }
}

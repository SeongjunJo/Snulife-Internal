import 'package:cloud_firestore/cloud_firestore.dart';

import 'commons/common_classes.dart';

class FirestoreReader {
  final _db = firebaseInstance.db;
  final _userId = firebaseInstance.userId;

  Future<String> getUserName() async {
    final userInfoField = _db.collection('users').doc(_userId).get();
    String userName = '';

    await userInfoField.then((DocumentSnapshot doc) {
      userName = doc['name'];
    });

    return userName;
  }

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

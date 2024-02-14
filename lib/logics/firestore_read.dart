import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';

import 'common_instances.dart';

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
      userInfo = MapUtil.convertDocumentSnapshot(
          doc, ['name', 'team', 'isSenior', 'position']);
    });

    return userInfo;
  }

  Future<Map<String, dynamic>> getClerkMap() async {
    final clerkCollection = _db.collection('clerks').get();
    Map<String, dynamic> clerkMap = {};

    await clerkCollection.then(
      (querySnapshot) {
        clerkMap = MapUtil.convertQuerySnapshot(querySnapshot, 'count');
      },
    );
    return clerkMap;
  }

  Future<String> getClerk() async {
    String clerk = '';
    Map<String, dynamic> clerkMap;

    clerkMap = await getClerkMap();
    clerk = MapUtil.getLeastKey(clerkMap);

    return clerk;
  }
}

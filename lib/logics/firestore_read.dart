import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';

import 'common_instances.dart';

class FirestoreReader {
  final _db = firebaseInstance.db;
  final _userId = firebaseInstance.userId;

  Future<Map<String, dynamic>> getUserInfo() async {
    final userInfoField = _db.collection('users').doc(_userId).get();
    Map<String, dynamic> userInfo = {};

    await userInfoField.then((DocumentSnapshot doc) {
      userInfo = MapUtil.convertDocumentSnapshot(
          doc, ['name', 'team', 'isSenior', 'position']);
    });

    return userInfo;
  }

  getClerkMap() async {
    QuerySnapshot<Map<String, dynamic>> clerkCollection;

    return memoizer.runOnce(() async {
      clerkCollection = await _db.collection('clerks').get();
      return MapUtil.convertQuerySnapshot(clerkCollection, 'count');
    });
  }

  Future<String> getClerk() async {
    String clerk = '';
    Map<String, dynamic> clerkMap;

    clerkMap = await getClerkMap();
    clerk = MapUtil.getLeastKey(clerkMap);

    return clerk;
  }

  getUserList() async {
    DocumentSnapshot<Map<String, dynamic>> userListDocument;

    return memoizer.runOnce(() async {
      userListDocument =
          await _db.collection('informations').doc('userList').get();
      return userListDocument.data()!['names'];
    });
  }

  getAttendanceStatus(String quarter, String date) {
    return firebaseInstance.db
        .collection('attendances')
        .doc(quarter)
        .collection('dates')
        .doc(date)
        .snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class MapUtil {
  static Map<String, dynamic> convertQuerySnapshot(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
    String key,
  ) {
    Map<String, dynamic> map = {};

    for (var docSnapshot in querySnapshot.docs) {
      map[docSnapshot.id] = docSnapshot.data()[key];
    }

    return map;
  }

  static Map<String, dynamic> convertDocumentSnapshot(
    DocumentSnapshot documentSnapshot,
    List<String> keys,
  ) {
    Map<String, dynamic> map = {};

    for (var key in keys) {
      map[key] = documentSnapshot[key];
    }

    return map;
  }

  static String getLeastKey(Map<String, dynamic> map) {
    // value가 int인 map 대상

    String leastKey = '';
    int leastValue = map.values
        .reduce((value, element) => value < element ? value : element);

    for (var key in map.keys) {
      if (map[key] == leastValue) {
        leastKey = key;
        break;
      }
    }
    return leastKey;
  }
}

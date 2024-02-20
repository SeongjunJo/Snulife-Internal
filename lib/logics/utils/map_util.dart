import 'package:cloud_firestore/cloud_firestore.dart';

class MapUtil {
  static Map<String, dynamic> orderClerksByCount(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
    String key,
  ) {
    Map<String, dynamic> map = {};

    for (var docSnapshot in querySnapshot.docs) {
      map[docSnapshot.id] = docSnapshot.data()[key];
    }
    map = Map.fromEntries(
        map.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

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

  static String getNextLeastKey(Map<String, dynamic> map) {
    // value가 int인 map 대상
    List<MapEntry<String, dynamic>> clerkList = map.entries.toList();
    String leastKey = getLeastKey(map);
    clerkList.removeWhere((element) => element.key == leastKey);
    Map<String, dynamic> newMap = Map.fromEntries(clerkList);

    int leastValue = newMap.values
        .reduce((value, element) => value < element ? value : element);

    for (var key in newMap.keys) {
      if (newMap[key] == leastValue) {
        leastKey = key;
        break;
      }
    }
    return leastKey;
  }
}

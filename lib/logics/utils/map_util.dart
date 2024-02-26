import 'package:cloud_firestore/cloud_firestore.dart';

class MapUtil {
  static Map<String, dynamic> orderClerksByCount(
    QuerySnapshot<Map<String, dynamic>> querySnapshot,
  ) {
    Map<String, dynamic> map = {};

    for (var docSnapshot in querySnapshot.docs) {
      map[docSnapshot.id] = docSnapshot.data()['count'];
    }
    map = Map.fromEntries(
        map.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)));

    return map;
  }

  static String getNextClerk(Map<String, dynamic> map, String clerk) {
    // value가 int인 map 대상
    String nextClerk = '';
    if (clerk.isEmpty) return '(미정)';
    List<MapEntry<String, dynamic>> clerkList = map.entries.toList();
    clerkList.removeWhere((element) => element.key == clerk); // 서기 2주 연속 금지
    Map<String, dynamic> newMap = Map.fromEntries(clerkList);

    int leastValue = newMap.values
        .reduce((value, element) => value < element ? value : element);

    for (var key in newMap.keys) {
      if (newMap[key] == leastValue) {
        nextClerk = key;
        break;
      }
    }
    return nextClerk;
  }
}

class AttendanceStatus {
  final String date;
  final String attendance;
  final bool isAuthorized;

  AttendanceStatus({
    required this.date,
    required this.attendance,
    required this.isAuthorized,
  });

  factory AttendanceStatus.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return AttendanceStatus(
      date: snapshot.id,
      attendance: data!['attendance'],
      isAuthorized: data['isAuthorized'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'attendance': attendance,
      'isAuthorized': isAuthorized,
    };
  }
}

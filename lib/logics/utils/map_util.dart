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
    String nextClerk = '';
    if (clerk.isEmpty) return '(미정)';
    List<MapEntry<String, dynamic>> clerkList = map.entries.toList();
    clerkList.removeWhere((element) => element.key == clerk); // 서기 2주 연속 금지
    Map<String, dynamic> newMap = Map.fromEntries(clerkList);

    if (newMap.isEmpty) return '미정'; // 신입 서기가 1명인 경우

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

  static Map<String, String> calculateAttendanceRateAndReward(
    Map<String, dynamic> originalPreSemesterSummary,
    Map<String, dynamic> originalPostSemesterSummary,
  ) {
    final Map<String, dynamic> emptySummaryTemplate = {
      'present': 0,
      'absent': 0,
      'late': 0,
      'badAbsent': 0,
      'badLate': 0,
      'sum': 0,
    };
    // 1, 3분기의 경우 2, 4분기라는 post summary가 없어서 빈 map이 들어옴
    final Map<String, dynamic> preSemesterSummary =
        Map.from(originalPreSemesterSummary);
    final Map<String, dynamic> postSemesterSummary =
        originalPostSemesterSummary.isEmpty
            ? Map.from(emptySummaryTemplate)
            : Map.from(originalPostSemesterSummary);
    // 복사 안하면 인자로 들어온 기존 데이터가 수정됨
    final List<Map<String, dynamic>> summaryList = [
      preSemesterSummary,
      postSemesterSummary
    ];
    final Map<String, dynamic> totalSummaryResult =
        Map.from(emptySummaryTemplate);
    final Map<String, String> result = {
      'attendanceRate': '',
      'reward': '',
      'totalMeeting': ''
    };
    late final double attendanceRate;
    late final double totalAbsence;
    late double reward;
    late final int penaltyPoint;

    for (final summary in summaryList) {
      if (summary['absent'] - 2 < 0) {
        // 분기당 사유 결석 2회까지 봐주고, 2회 미만이면 사유 지각을 0.5회로 쳐서 남은 횟수만큼 봐줌
        int absentBonus = 2 - (summary['absent'] as int);
        summary['absent'] = 0;
        summary['late'] - absentBonus * 2 < 0
            ? summary['late'] = 0
            : summary['late'] -= absentBonus * 2;
      } else {
        summary['absent'] -= 2;
      }
      totalSummaryResult['present'] += summary['present'];
      totalSummaryResult['absent'] += summary['absent'];
      totalSummaryResult['late'] += summary['late'];
      totalSummaryResult['badAbsent'] += summary['badAbsent'];
      totalSummaryResult['badLate'] += summary['badLate'];
      totalSummaryResult['sum'] += summary['sum'];
    }

    totalAbsence = totalSummaryResult['absent'] +
        totalSummaryResult['badAbsent'] +
        totalSummaryResult['late'] / 2 +
        totalSummaryResult['badLate'] / 2;
    attendanceRate = (totalSummaryResult['sum'] - totalAbsence) /
        totalSummaryResult['sum'] *
        100;

    penaltyPoint = totalSummaryResult['badAbsent'] * 10 +
        totalSummaryResult['absent'] * 5 +
        totalSummaryResult['badLate'] * 2 +
        totalSummaryResult['late'];

    switch (attendanceRate) {
      case 100:
        reward = 8;
      case >= 90:
        reward = 5;
      case >= 80:
        reward = 2;
      default:
        reward = 0;
    }
    reward *= (100 - penaltyPoint) / 100;

    result['attendanceRate'] =
        attendanceRate.toStringAsFixed(2); // 소수점 셋째자리에서 반올림
    result['reward'] = reward.toStringAsFixed(2); // 부동 소수점 문제로 반올림
    result['totalMeeting'] = totalSummaryResult['sum'].toString();

    return result;
  }
}

class AttendanceStatus {
  final String dateWithYear;
  final String date;
  final String attendance;
  final bool isAuthorized;

  AttendanceStatus({
    required this.dateWithYear,
    required this.date,
    required this.attendance,
    required this.isAuthorized,
  });

  factory AttendanceStatus.fromFirestore(
      String semester,
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final year = int.parse(semester.split('-').first);
    final semesterText = semester.split('-').last;
    final data = snapshot.data();

    return AttendanceStatus(
      dateWithYear: // 겨울학기 12월 -> 1월 넘어갈 때 sort 문제 해결
          '${semesterText == 'W' && snapshot.id.substring(0, 2) == '12' ? year : year + 1} + ${snapshot.id}',
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

class UserInfo {
  UserInfo({
    required this.name,
    required this.position,
    required this.team,
    required this.isSenior,
    required this.isAlum,
    required this.year,
    required this.promotionCount,
    required this.isRest,
  });

  final String name;
  final String team;
  final String position;
  final bool isSenior;
  final bool isAlum;
  final int year;
  final int promotionCount;
  final bool isRest;

  factory UserInfo.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data();
    return UserInfo(
      // 신입 추가 직전의 상황 => firestore에 이름만 있음
      name: data!['name'],
      team: data['team'] ?? '미정',
      position: data['position'] ?? '팀원',
      isSenior: data['isSenior'] ?? false,
      isAlum: data['isAlum'] ?? false,
      isRest: data['isRest'] ?? false,
      year: data['year'] ?? 0,
      promotionCount: data['promotionCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'team': team,
      'position': position,
      'isSenior': isSenior,
      'isAlum': isAlum,
      'isRest': isRest,
      'year': year,
      'promotionCount': promotionCount,
    };
  }
}

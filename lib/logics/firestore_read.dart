import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snulife_internal/logics/utils/html_util.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

import 'common_instances.dart';

class FirestoreReader {
  final _db = firebaseInstance.db;

  Future<List<String>> getUserList() async {
    final userListDocument =
        await _db.collection('information').doc('userList').get();
    final List<String> userList =
        userListDocument.data()!['names'].cast<String>();
    userList.sort();

    return userList;
  }

  Future getUserInfo(String name) async {
    final userListDocument =
        await _db.collection('users').where('name', isEqualTo: name).get();
    return userListDocument.docs.first.data();
  }

  Future findClerkDate(String currentSemester, String? upcomingSemester) async {
    final today = StringUtil.convertDateTimeToString(DateTime.now(), true);

    final meetingDatesQuery = await firebaseInstance.db
        .collection('attendances')
        .doc(currentSemester)
        .collection('dates')
        .get();

    for (final date in meetingDatesQuery.docs) {
      // 다음 회의 문서 찾기
      if (int.parse(date.id) >= int.parse(today)) return date.id;
    }
    // 분기가 바뀌어서 return 못했으면 다음 학기의 첫 회의 문서 찾기
    final nextMeetingDatesQuery = await firebaseInstance.db
        .collection('attendances')
        .doc(upcomingSemester)
        .collection('dates')
        .get();
    return nextMeetingDatesQuery.docs.first.id;
  }

  Stream<DocumentSnapshot<Map>> getPeopleAttendanceAndClerkStream(
      String semester, String date) {
    return firebaseInstance.db
        .collection('attendances')
        .doc(semester)
        .collection('dates')
        .doc(date)
        .snapshots();
  }

  Future checkHasMeetingStarted() async {
    final now = DateTime.now();
    late final currentTime = StringUtil.convertDateTimeToString(now, false);
    late final DocumentSnapshot meetingTimeInfo;

    await memoizer.runOnce(() async {
      meetingTimeInfo = await firebaseInstance.db
          .collection('information')
          .doc('meetingTime')
          .get();
    });

    return int.parse(currentTime) >= int.parse(meetingTimeInfo['time']);
  }

  Future getSemesterDateTimeList() async {
    final academicCalendarHtml = await httpLogic.getAcademicCalendar();
    final semesterDurationList =
        HtmlUtil.getSemesterDuration(academicCalendarHtml);
    return StringUtil.getSemesterDateTime(semesterDurationList);
  }

  Future<List<String>> getCurrentAndUpcomingSemesters() async {
    late List<String> semesters;
    Index index = Index.winter; // 디폴트 값

    final List<DateTime> semesterDateTimeList = await getSemesterDateTimeList();
    final DateTime now = DateTime.now();
    final yearText = now.year;

    for (int i = 0; i < semesterDateTimeList.length; i++) {
      if (now.isBefore(semesterDateTimeList[i])) {
        index = Index.values[i];
        break;
      }
    }

    switch (index) {
      case Index.lastWinter:
        semesters = ['${yearText - 1}-W', '$yearText-1'];
      case Index.spring:
        semesters = ['$yearText-1', '$yearText-S'];
      case Index.summer:
        semesters = ['$yearText-S', '$yearText-2'];
      case Index.fall:
        semesters = ['$yearText-2', '$yearText-W'];
      case Index.winter:
        semesters = ['$yearText-W', '${yearText + 1}-1'];
    }

    final upcomingSemester =
        await _db.collection('attendances').doc(semesters[1]).get();

    if (!upcomingSemester.exists) semesters.removeAt(1);

    return semesters; // 다음 학기가 db에 등록되어 있으면 2개 학기, 없으면 1개 학기
  }

  getMyAttendanceStatusListener(
    String semester,
    Function setState,
    List<AttendanceStatus> attendanceStatus,
  ) {
    return firebaseInstance.db
        .collection('attendances')
        .doc(semester)
        .collection(firebaseInstance.userName!)
        .where('attendance', isNull: false) // 컬렉션에서 summary 문서는 제외
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added: // 최초 리스너 등록 이후 added 발생 불가
            attendanceStatus.add(
                AttendanceStatus.fromFirestore(semester, change.doc, null));
          case DocumentChangeType.modified:
            attendanceStatus
                .removeWhere((element) => element.date == change.doc.id);
            attendanceStatus.add(
                AttendanceStatus.fromFirestore(semester, change.doc, null));
          case DocumentChangeType.removed: // 문서 삭제 경우 발생 불가
            return;
        }
      }
      attendanceStatus.sort((a, b) => a.dateWithYear.compareTo(b.dateWithYear));
      setState();
    });
  }

  Future<DocumentSnapshot<Map>> getMyAttendanceSummary(
          String semester, String name) async =>
      firebaseInstance.db
          .collection('attendances')
          .doc(semester)
          .collection(name)
          .doc('summary')
          .get();

  Future<List> getMyAttendanceHistory(
      String semester, String name, bool? makeFuture) async {
    List<AttendanceStatus> temp = [];
    List<AttendanceStatus> attendanceHistory;

    final attendanceCollection = await firebaseInstance.db
        .collection('attendances')
        .doc(semester)
        .collection(name)
        .where('attendance', isNull: false)
        .get(); // 컬렉션에서 summary 문서는 제외
    for (var doc in attendanceCollection.docs) {
      temp.add(AttendanceStatus.fromFirestore(semester, doc, null));
    }
    attendanceHistory = StringUtil.adjustListWithDate(temp, makeFuture);
    attendanceHistory.sort((a, b) => a.dateWithYear.compareTo(b.dateWithYear));

    return attendanceHistory;
  }

  Future<List<Map<String, String>>> getQSMapList(
      List userList, String preSemester, String postSemester) async {
    final List<Map<String, String>> userQSMapList = [];

    for (final user in userList) {
      late final DocumentSnapshot<Map> preSummary;
      late final DocumentSnapshot<Map> postSummary;
      late final Map<String, dynamic> preSummaryMap;
      late final Map<String, dynamic> postSummaryMap;

      final futureList = await Future.wait([
        firestoreReader.getMyAttendanceSummary(preSemester, user),
        firestoreReader.getMyAttendanceSummary(postSemester, user),
      ]);
      preSummary = futureList[0];
      postSummary = futureList[1];
      preSummaryMap = preSummary.data()! as Map<String, dynamic>;
      postSummary.exists
          ? postSummaryMap = postSummary.data()! as Map<String, dynamic>
          : {};
      userQSMapList.add(MapUtil.calculateAttendanceRateAndReward(
          preSummaryMap, postSummaryMap));
    }
    return userQSMapList;
  }
}

enum Index {
  lastWinter,
  spring,
  summer,
  fall,
  winter,
}

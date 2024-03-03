import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';
import 'package:snulife_internal/logics/utils/html_util.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

import 'common_instances.dart';

class FirestoreReader {
  final _db = firebaseInstance.db;

  Future getUserList() async {
    return memoizer.runOnce(() async {
      final userListDocument =
          await _db.collection('information').doc('userList').get();
      return userListDocument.data()!['names'];
    });
  }

  Future getUserInfo(String name) async {
    final userListDocument =
        await _db.collection('users').where('name', isEqualTo: name).get();
    return userListDocument.docs.first.data();
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
    final now = DateUtil.getLocalNow();
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
    final DateTime now = DateUtil.getLocalNow();
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
            attendanceStatus
                .add(AttendanceStatus.fromFirestore(change.doc, null));
          case DocumentChangeType.modified:
            attendanceStatus
                .removeWhere((element) => element.date == change.doc.id);
            attendanceStatus
                .add(AttendanceStatus.fromFirestore(change.doc, null));
          case DocumentChangeType.removed: // 문서 삭제 경우 발생 불가
            return;
        }
      }
      attendanceStatus.sort((a, b) => a.date.compareTo(b.date));
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

  Future<List> getMyAttendanceHistory(String semester, String name) async {
    List<AttendanceStatus> temp = [];
    List<AttendanceStatus> attendanceHistory;

    final attendanceCollection = await firebaseInstance.db
        .collection('attendances')
        .doc(semester)
        .collection(name)
        .where('attendance', isNull: false)
        .get(); // 컬렉션에서 summary 문서는 제외
    for (var doc in attendanceCollection.docs) {
      temp.add(AttendanceStatus.fromFirestore(doc, null));
    }
    attendanceHistory = StringUtil.adjustListWithDate(temp, false);
    attendanceHistory.sort((a, b) => a.date.compareTo(b.date));

    return attendanceHistory;
  }

  Future getQSMapList(
      List userList, String preSemester, String postSemester) async {
    final List<Map<String, String>> userQSMapList = [];

    for (final user in userList) {
      late final DocumentSnapshot<Map> preSummary;
      late final DocumentSnapshot<Map> postSummary;
      late final Map<String, dynamic> preSummaryMap;
      late final Map<String, dynamic> postSummaryMap;

      final futureList = await Future.wait([
        // TODO user로 바꾸기
        firestoreReader.getMyAttendanceSummary(preSemester, '홍신입'),
        firestoreReader.getMyAttendanceSummary(postSemester, '홍신입'),
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

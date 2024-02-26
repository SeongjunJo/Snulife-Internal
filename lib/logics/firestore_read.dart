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
          await _db.collection('informations').doc('userList').get();
      return userListDocument.data()!['names'];
    });
  }

  getPeopleAttendanceAndClerkStream(String semester, String date) {
    return firebaseInstance.db
        .collection('attendances')
        .doc(semester)
        .collection('dates')
        .doc(date)
        .snapshots();
  }

  Future checkHasMeetingStarted() async {
    final now = DateUtil.getLocalNow();
    late final hour = now.hour.toString().padLeft(2, '0');
    late final minute = now.minute.toString().padLeft(2, '0');
    late final currentTime = hour + minute;

    return memoizer.runOnce(() async {
      final meetingTimeInfo = await firebaseInstance.db
          .collection('informations')
          .doc('meetingTime')
          .get();
      final meetingTime = meetingTimeInfo.data()!['time'];
      return int.parse(currentTime) >= int.parse(meetingTime);
    });
  }

  Future<List<String>> getCurrentAndUpcomingSemesters() async {
    late final String academicCalendarHtml;
    late List<String> semesters;
    Index index = Index.winter; // 디폴트 값
    late final DocumentSnapshot upcomingSemester;

    academicCalendarHtml = await httpLogic.getAcademicCalendar();
    final List<String> semesterDuration =
        HtmlUtil.getSemesterDuration(academicCalendarHtml);
    final List<DateTime> semesterDatetime =
        StringUtil.getSemesterDatetime(semesterDuration);

    final DateTime now = DateUtil.getLocalNow();
    final yearText = now.year;

    for (int i = 0; i < semesterDatetime.length; i++) {
      if (now.isBefore(semesterDatetime[i])) {
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

    upcomingSemester =
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

  Future<DocumentSnapshot> getMyAttendanceSummary(String semester) async =>
      firebaseInstance.db
          .collection('attendances')
          .doc(semester)
          .collection(firebaseInstance.userName!)
          .doc('summary')
          .get();

  Future<List> getMyAttendanceHistory(String semester) async {
    List<AttendanceStatus> temp = [];
    List<AttendanceStatus> attendanceHistory;

    final attendanceCollection = await firebaseInstance.db
        .collection('attendances')
        .doc(semester)
        .collection(firebaseInstance.userName!)
        .where('attendance', isNull: false)
        .get(); // 컬렉션에서 summary 문서는 제외
    for (var doc in attendanceCollection.docs) {
      temp.add(AttendanceStatus.fromFirestore(doc, null));
    }
    attendanceHistory = StringUtil.adjustListWithDate(temp, false);
    attendanceHistory.sort((a, b) => a.date.compareTo(b.date));

    return attendanceHistory;
  }
}

enum Index {
  lastWinter,
  spring,
  summer,
  fall,
  winter,
}

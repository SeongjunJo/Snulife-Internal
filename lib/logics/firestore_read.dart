import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snulife_internal/logics/utils/html_util.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

import 'common_instances.dart';

class FirestoreReader {
  final _db = firebaseInstance.db;
  final _userId = firebaseInstance.userId;

  Future<Map<String, dynamic>> getUserInfo() async {
    final userInfoField = _db.collection('users').doc(_userId).get();
    Map<String, dynamic> userInfo = {};

    await userInfoField.then((DocumentSnapshot doc) {
      userInfo = MapUtil.convertDocumentSnapshotToMap(
          doc, ['name', 'team', 'isSenior', 'position']);
    });

    return userInfo;
  }

  getClerkMap() async {
    QuerySnapshot<Map<String, dynamic>> clerkCollection;

    return memoizer.runOnce(() async {
      clerkCollection = await _db.collection('clerks').get();
      return MapUtil.convertQuerySnapshotToMap(clerkCollection, 'count');
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

  getPeopleAttendanceStream(String quarter, String date) {
    return firebaseInstance.db
        .collection('attendances')
        .doc(quarter)
        .collection('dates')
        .doc(date)
        .snapshots();
  }

  Future<List<String>> getCurrentAndComingSemester() async {
    late final String academicCalendarHtml;
    late List<String> semesters;
    Index index = Index.winter;

    academicCalendarHtml = await httpLogic.getAcademicCalendar();
    List<String> semesterDuration =
        HtmlUtil.getSemesterDuration(academicCalendarHtml);
    List<DateTime> semesterDatetime =
        StringUtil.getSemesterDatetime(semesterDuration);

    DateTime now = DateTime.now();
    int yearText = now.year;

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

    return semesters;
  }

  Future<List<dynamic>?> getMyAttendanceStatus(List<String> semesters) async {
    final List<dynamic> attendanceStatus = [
      semesters[0],
      semesters[1]
    ]; // 현재 학기 & 다음 학기

    for (String semester in semesters) {
      final semesterDocument = _db.collection('attendances').doc(semester);
      final doesDocumentExist = await semesterDocument.get();

      if (doesDocumentExist.exists) {
        QuerySnapshot<Map<String, dynamic>> attendanceDocuments = await _db
            .collection('attendances')
            .doc(semester)
            .collection(firebaseInstance.userName!)
            .where('attendance', isNull: false)
            .get();
        attendanceStatus
            .add(StringUtil.convertQuerySnapshotToList(attendanceDocuments));
      }
    }

    return attendanceStatus; // 현재 학기 & 다음 학기 & 현재 학기 dates & 다음 학기 dates(또는 null)
  }

  getMyAttendanceStatusListener(
    String currentSemester,
    Function setState,
  ) {
    return firebaseInstance.db
        .collection('attendances')
        .doc(currentSemester)
        .collection(firebaseInstance.userName!)
        .where('attendance', isNull: false)
        .snapshots()
        .listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added: // 최초 리스너 등록 이후 added 발생 불가
            print("New City: ${change.doc.data()}");
          case DocumentChangeType.modified:
            print("Modified City: ${change.doc.data()}");
          case DocumentChangeType.removed: // 문서 삭제 경우 발생 불가
            return;
        }
      }
      setState();
    });
  }
}

enum Index {
  lastWinter,
  spring,
  summer,
  fall,
  winter,
}

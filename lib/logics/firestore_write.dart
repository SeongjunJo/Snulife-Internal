import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snulife_internal/logics/utils/html_util.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

import 'common_instances.dart';

class FirestoreWriter {
  final _db = firebaseInstance.db;

  Future<void> writeMyLateAbsence(
      String semester, List<AttendanceStatus> statusList, bool isLate) async {
    for (var status in statusList) {
      final myAttendanceDocumentRef = _db
          .collection('attendances')
          .doc(semester)
          .collection(firebaseInstance.userName!)
          .doc(status.date);
      final peopleAttendanceDocumentRef = _db
          .collection('attendances')
          .doc(semester)
          .collection('dates')
          .doc(status.date);
      final documents = await Future.wait(
          [myAttendanceDocumentRef.get(), peopleAttendanceDocumentRef.get()]);
      if (documents[0].exists) {
        myAttendanceDocumentRef.update({
          'attendance': isLate ? '지각' : '결석',
          'isAuthorized': true,
        });
      }
      if (documents[1].exists) {
        peopleAttendanceDocumentRef.update({
          isLate ? 'late' : 'absent':
              FieldValue.arrayUnion([firebaseInstance.userName!]),
        });
      }
    }
  }

  Future<void> writeConfirmedClerk(
    // 이번 & 다음 서기 기록, 서기인 사람 count 증가
    String currentSemester, // nextClerk 써야 하는데 다음주 id의 문서가 없으면 다음 학기 첫 문서에 씀
    String? upcomingSemester,
    String thisWeekClerkDate,
    String clerk,
    String nextClerk,
    bool isTemporaryClerk,
  ) async {
    final year = int.parse(thisWeekClerkDate) >= 1225
        ? DateTime.now().year + 1 // 다음주가 내년인 경우 (12월 25일 ~ 12월 31일)
        : DateTime.now().year;
    final thisWeekDateTime =
        StringUtil.convertStringToDateTime(year, thisWeekClerkDate);
    final nextWeekDateId = StringUtil.convertDateTimeToString(
        thisWeekDateTime.add(const Duration(days: 7)), true);
    String nextSemesterDateId = '9999'; // 충분히 큰 숫자

    final todayClerkDocumentRef = _db
        .collection('attendances')
        .doc(currentSemester)
        .collection('dates')
        .doc(thisWeekClerkDate);
    final nextClerkDocumentRef = _db
        .collection('attendances')
        .doc(currentSemester)
        .collection('dates')
        .doc(nextWeekDateId);

    todayClerkDocumentRef.update({'clerk': clerk}); // 이번 서기 확정해서 기록
    !isTemporaryClerk
        ? _db
            .collection('clerks')
            .doc(clerk)
            .update({'count': FieldValue.increment(1)}) // 이번 서기 횟수 +1
        : null;

    final nextClerkDocument = await nextClerkDocumentRef.get();
    if (nextClerkDocument.exists) {
      // 다음주 문서 있으면 다음 서기 기록
      nextClerkDocumentRef.update({'clerk': nextClerk});
    } else {
      // 다음주 문서 없으면 다음 학기 문서 존재하는지 검색
      final nextSemesterCollection =
          await _db.collection('attendances').doc(upcomingSemester).get();
      if (nextSemesterCollection.exists) {
        // 다음 학기 문서 있으면 가장 최근 날짜 문서 추출
        final nextSemesterClerkCollectionRef = await _db
            .collection('attendances')
            .doc(upcomingSemester)
            .collection('dates')
            .get();
        for (var doc in nextSemesterClerkCollectionRef.docs) {
          if (int.parse(doc.id) < int.parse(nextSemesterDateId)) {
            nextSemesterDateId = doc.id;
          }
        }
        _db
            .collection('attendances')
            .doc(upcomingSemester)
            .collection('dates')
            .doc(nextSemesterDateId)
            .update({'clerk': nextClerk});
      }
    }
  }

  saveAttendanceStatus(
    String semester,
    Map<String, List<dynamic>> userAttendanceStatus,
    bool isConfirm,
  ) {
    final today = StringUtil.convertDateTimeToString(DateTime.now(), true);
    final presentList = [];
    final lateList = [];
    final absentList = [];
    final badLateList = [];
    final badAbsentList = [];

    for (final user in userAttendanceStatus.keys) {
      switch (userAttendanceStatus[user]!.first) {
        case '출석':
          presentList.add(user);
        case '지각':
          userAttendanceStatus[user]!.last
              ? lateList.add(user)
              : badLateList.add(user);
        case '결석':
          userAttendanceStatus[user]!.last
              ? absentList.add(user)
              : badAbsentList.add(user);
        default: // 출석 체크를 안 해서 ''인 경우는 pass
      }
    }

    _db
        .collection('attendances')
        .doc(semester)
        .collection('dates')
        .doc(today)
        .update({
      'present': presentList,
      'late': lateList,
      'absent': absentList,
      'badLate': badLateList,
      'badAbsent': badAbsentList,
      'hasAttendanceConfirmed': isConfirm,
    });
  }

  confirmAttendanceStatus(
      String semester, Map<String, List<dynamic>> userAttendanceStatus) {
    final today = StringUtil.convertDateTimeToString(DateTime.now(), true);
    late final String attendance;
    late final bool isAuthorized;
    late final String summaryAttendance;

    for (final user in userAttendanceStatus.keys) {
      attendance = userAttendanceStatus[user]!.first;
      isAuthorized = userAttendanceStatus[user]!.last;
      switch (attendance) {
        case '출석':
          summaryAttendance = 'present';
        case '지각':
          isAuthorized
              ? summaryAttendance = 'late'
              : summaryAttendance = 'badLate';
        case '결석':
          isAuthorized
              ? summaryAttendance = 'absent'
              : summaryAttendance = 'badAbsent';
      }

      _db
          .collection('attendances')
          .doc(semester)
          .collection(user)
          .doc(today)
          .set({'attendance': attendance, 'isAuthorized': isAuthorized});

      _db
          .collection('attendances')
          .doc(semester)
          .collection(user)
          .doc('summary')
          .update({
        'sum': FieldValue.increment(1),
        summaryAttendance: FieldValue.increment(1),
      });
    }
  }

  Future<List> confirmRestDate(String semester, List<String> dates) async {
    final List<dynamic> userList = await firestoreReader.getUserList();
    final List<Future<void>> updateList = [];

    updateList.add(_db
        .collection('information')
        .doc('meetingTime')
        .update({'rest': FieldValue.arrayUnion(dates)}));

    for (final user in userList) {
      for (final date in dates) {
        updateList.add(_db
            .collection('attendances')
            .doc(semester)
            .collection(user)
            .doc(date)
            .update({'attendance': '휴회', 'isAuthorized': true}));
      }
    }

    return Future.wait(updateList);
  }

  Future<List<String>> createMeetingTimeList(
      String startDate, String nextSemester) async {
    final academicCalendarHtml = await httpLogic.getAcademicCalendar();
    final semesterDurationList =
        HtmlUtil.getSemesterDuration(academicCalendarHtml);
    final semesterDateTimeList =
        StringUtil.getSemesterDateTime(semesterDurationList);

    final currentYear = DateTime.now().year;
    final DateTime startDateTime =
        StringUtil.convertStringToDateTime(currentYear, startDate);
    late final DateTime endDateTime;
    DateTime meetingTime = startDateTime;
    final List<String> meetingTimeList = [];

    switch (nextSemester.split('-').last) {
      case '1':
        endDateTime = semesterDateTimeList[1]
            .add(const Duration(days: 1)); // 1학기 종강일자는 회의일 가능
      case 'S':
        endDateTime = semesterDateTimeList[2]; // 2학기 개강일자는 회의일 불가능
      case '2':
        endDateTime = semesterDateTimeList[3]
            .add(const Duration(days: 1)); // 2학기 종강일자는 회의일 가능
      case 'W':
        final int nextYear = currentYear + 1;
        // 내년 1학기 개강일자는 올해 학사일정에 안 나와서 내년 3월 1일을 기준으로 함; 3월 2일 전까지 회의일 가능
        endDateTime = DateTime(nextYear, 3, 2);
    }

    while (meetingTime.isBefore(endDateTime)) {
      meetingTimeList
          .add(StringUtil.convertDateTimeToString(meetingTime, true));
      meetingTime = meetingTime.add(const Duration(days: 7));
    }

    return meetingTimeList;
  }

  Future createNextMeeting(
      String currentSemester, String startDate, String time) async {
    final yearText = currentSemester.split('-').first;
    final semesterText = currentSemester.split('-').last;
    late final String nextSemester;
    final batch = _db.batch(); // 한 번에 500번 쓰기 가능; 회의 평균 15회 * 동아리원 20명 이하

    switch (semesterText) {
      case '1':
        nextSemester = '$yearText-S';
      case 'S':
        nextSemester = '$yearText-2';
      case '2':
        nextSemester = '$yearText-W';
      case 'W':
        nextSemester = '${int.parse(yearText) + 1}-1';
    }

    final futureList = await Future.wait([
      createMeetingTimeList(startDate, nextSemester),
      firestoreReader.getUserList()
    ]);
    final List<String> meetingTimeList = futureList[0].cast<String>();
    final List<String> userList = futureList[1].cast<String>();

    final nextSemesterRef = _db.collection('attendances').doc(nextSemester);
    await nextSemesterRef.set({}); // 상위 문서를 생성해둬야 함

    batch.set(_db.collection('information').doc('meetingTime'), {
      'rest': [],
      'teamMeeting': [],
      'time': time,
    });

    batch.set(nextSemesterRef, {
      'hasQSConfirmed':
          int.tryParse(nextSemester.split('-').last) == null ? false : true
      // 반기의 마지막 학기면 false, 아니면 true
    });

    for (final meetingTime in meetingTimeList) {
      batch.set(nextSemesterRef.collection('dates').doc(meetingTime), {
        'present': [],
        'absent': [],
        'late': [],
        'badAbsent': [],
        'badLate': [],
        'clerk': '',
        'hasAttendanceConfirmed': false,
        'hasClerkConfirmed': false,
      });
    }

    for (final user in userList) {
      for (final meetingTime in meetingTimeList) {
        batch.set(nextSemesterRef.collection(user).doc(meetingTime), {
          'attendance': '',
          'isAuthorized': false,
        });
        batch.set(nextSemesterRef.collection(user).doc('summary'), {
          'present': 0,
          'absent': 0,
          'late': 0,
          'badAbsent': 0,
          'badLate': 0,
          'sum': 0,
        });
      }
    }

    await batch.commit();
  }

  Future registerNewUser(
    UserInfo newUser,
    String currentSemester,
    List peopleInfoList,
  ) async {
    final db = firebaseInstance.db;
    final batch = db.batch();
    final meetingDatesList = <String>[];
    final today = StringUtil.convertDateTimeToString(DateTime.now(), true);
    final youngestYear =
        peopleInfoList.map((e) => e.year).reduce((a, b) => a > b ? a : b);

    if (newUser.year > youngestYear) {
      // 신입 기수 오면 기존 서기 해방
      for (final user in peopleInfoList) {
        batch.delete(db.collection('clerks').doc(user.name));
      }
    }

    final userRef = await db
        .collection('users')
        .withConverter(
          fromFirestore: UserInfo.fromFirestore,
          toFirestore: (UserInfo userInfo, _) => userInfo.toFirestore(),
        )
        .where('name', isEqualTo: newUser.name)
        .get();

    final meetingDatesQuery = await firebaseInstance.db
        .collection('attendances')
        .doc(currentSemester)
        .collection(firebaseInstance.userName!)
        .where('attendance', isNull: false)
        .get();

    batch.set(userRef.docs.first.reference, newUser); // users 컬렉션에 유저 정보 등록

    batch.update(db.collection('information').doc('userList'), {
      'names': FieldValue.arrayUnion([newUser.name]), // userList 명단에 이름 등록
    });

    batch.set(db.collection('clerks').doc(newUser.name), {'count': 0}); // 서기 등록

    for (final doc in meetingDatesQuery.docs) {
      meetingDatesList.add(doc.id);
    }
    meetingDatesList.removeWhere(
        (element) => int.parse(element) < int.parse(today)); // 신입 들어오기 전 날짜 제거
    for (final date in meetingDatesList) {
      batch.set(
        db
            .collection('attendances')
            .doc(currentSemester)
            .collection(newUser.name)
            .doc(date),
        {'attendance': '', 'isAuthorized': false},
      ); // 출결 등록
    }

    batch.set(
      db
          .collection('attendances')
          .doc(currentSemester)
          .collection(newUser.name)
          .doc('summary'),
      {
        'present': 0,
        'absent': 0,
        'late': 0,
        'badAbsent': 0,
        'badLate': 0,
        'sum': 0,
      },
    ); // 출결 등록

    await batch.commit();
  }

  Future updatePeopleInfo(List<Map<String, dynamic>> updatedInfoList) async {
    final db = firebaseInstance.db;
    final batch = db.batch();

    final userQuery = await db
        .collection('users')
        .withConverter(
            fromFirestore: UserInfo.fromFirestore,
            toFirestore: (UserInfo userInfo, _) => userInfo.toFirestore())
        .get();

    for (final userInfo in updatedInfoList) {
      final index = userQuery.docs
          .indexWhere((element) => element.data().name == userInfo['name']);
      if (userInfo.containsKey('isRest') && userInfo['isRest'] == null) {
        // 탈퇴
        batch.delete(userQuery.docs[index].reference);
        batch.update(db.collection('information').doc('userList'), {
          'names': FieldValue.arrayRemove([userInfo['name']]),
        });
        batch.delete(db.collection('clerks').doc(userInfo['name']));
      } else {
        batch.update(userQuery.docs[index].reference, userInfo);
      }
    }

    await batch.commit();
  }
}

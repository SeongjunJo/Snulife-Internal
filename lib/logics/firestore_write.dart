import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';

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
      final myAttendanceDocument = await myAttendanceDocumentRef.get();
      bool doesDocumentExist = myAttendanceDocument.exists;
      if (doesDocumentExist) {
        await myAttendanceDocumentRef.update({
          'attendance': isLate ? '지각' : '결석',
          'isAuthorized': true,
        });
      }
    }
  }

  Future<void> writeConfirmedClerk(
    // 이번 & 다음 서기 기록, 서기인 사람 count 증가
    String currentSemester, // nextClerk 써야 하는데 다음주 id의 문서가 없으면 다음 학기 첫 문서에 씀
    String? upcomingSemester,
    String clerk,
    String nextClerk,
  ) async {
    final nextWeekDate = DateTime.now().add(const Duration(days: 7, hours: 9));
    final month = nextWeekDate.month.toString().padLeft(2, '0');
    final day = nextWeekDate.day.toString().padLeft(2, '0');
    final nextWeekDateId = month + day;
    String nextSemesterDateId = '9999'; // 충분히 큰 4자리 숫자

    final todayClerkDocumentRef = _db
        .collection('attendances')
        .doc(currentSemester)
        .collection('dates')
        // TODO localToday로 바꾸기
        .doc('0229');
    final nextClerkDocumentRef = _db
        .collection('attendances')
        .doc(currentSemester)
        .collection('dates')
        // TODO nextWeekDateId로 바꾸기
        .doc('0301');

    await todayClerkDocumentRef.update({'clerk': clerk}); // 오늘 서기 확정해서 기록
    await _db
        .collection('clerks')
        .doc(clerk)
        .update({'count': FieldValue.increment(1)}); // 오늘 서기 횟수 +1

    final nextClerkDocument = await nextClerkDocumentRef.get();
    if (nextClerkDocument.exists) {
      // 다음주 문서 있으면 다음 서기 기록
      await nextClerkDocumentRef.update({'clerk': nextClerk});
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
        await _db
            .collection('attendances')
            .doc(upcomingSemester)
            .collection('dates')
            .doc(nextSemesterDateId)
            .update({'clerk': nextClerk});
      }
    }
  }
}

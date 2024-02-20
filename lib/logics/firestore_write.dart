import 'package:flutter/material.dart';
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
        debugPrint('Document: ${myAttendanceDocument.data()}');
        debugPrint('Document ID: ${myAttendanceDocument.id}');
        debugPrint('data: ${status.date}');
        await myAttendanceDocumentRef.update({
          'attendance': isLate ? '지각' : '결석',
          'isAuthorized': true,
        });
      }
    }
  }
}

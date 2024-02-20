import 'package:cloud_firestore/cloud_firestore.dart';

class StringUtil {
  static List<DateTime> getSemesterDatetime(List<String> semesterDuration) {
    List<DateTime> semesterDatetime = [];

    for (var semester in semesterDuration) {
      final year = int.parse(semester.substring(0, 4));
      final month = int.parse(semester.substring(5, 7));
      final day = int.parse(semester.substring(8, 10));
      semesterDatetime.add(DateTime(year, month, day));
    }

    return semesterDatetime;
  }

  static List<AttendanceStatus> convertDocumentSnapshotToList(
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
    List<AttendanceStatus> attendanceStatus = [];

    attendanceStatus.add(AttendanceStatus.fromFirestore(documentSnapshot));

    attendanceStatus.sort((a, b) => a.date.compareTo(b.date));

    return attendanceStatus;
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
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
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

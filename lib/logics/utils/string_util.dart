import 'map_util.dart';

class StringUtil {
  static String convertDateTimeToString(DateTime dateTime, bool isDate) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return isDate ? month + day : hour + minute;
  }

  static DateTime convertStringToDateTime(int year, String string) {
    final month = int.parse(string.substring(0, 2));
    final day = int.parse(string.substring(2, 4));

    return DateTime(year, month, day);
  }

  static List<DateTime> getSemesterDateTime(List<String> semesterDuration) {
    List<DateTime> semesterDateTimeList = [];

    for (var semester in semesterDuration) {
      final year = int.parse(semester.substring(0, 4));
      final month = int.parse(semester.substring(5, 7));
      final day = int.parse(semester.substring(8, 10));
      semesterDateTimeList.add(DateTime(year, month, day));
    }

    return semesterDateTimeList;
  }

  static List<AttendanceStatus> adjustListWithDate(
    List<AttendanceStatus> list,
    bool? makeFuture, // 미래만 남길지, 과거만 남길지 (null이면 아무 작업 안 함)
  ) {
    final today = StringUtil.convertDateTimeToString(DateTime.now(), true);
    final List<AttendanceStatus> adjustedList =
        List.from(list); // 복사 안 하면 인자로 받는 list가 바뀜
    if (makeFuture == true) {
      adjustedList
          .removeWhere((element) => int.parse(element.date) < int.parse(today));
    } else if (makeFuture == false) {
      adjustedList.removeWhere(
          (element) => int.parse(element.date) >= int.parse(today));
    }
    return adjustedList;
  }

  static List<String> convertHalfToQuarters(String half) {
    final currentYear = int.parse(half.substring(0, 4));
    final currentHalf = half.split(' ')[1];
    late final List<String> quarters;

    currentHalf == '상반기'
        ? quarters = ['$currentYear-1', '$currentYear-S']
        : quarters = ['$currentYear-2', '$currentYear-W'];

    return quarters;
  }
}

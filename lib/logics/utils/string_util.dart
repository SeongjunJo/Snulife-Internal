import 'package:snulife_internal/logics/common_instances.dart';

import 'map_util.dart';

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

  static List<AttendanceStatus> adjustListWithDate(
    List<AttendanceStatus> list,
    bool makeFuture, // 미래만 남길지, 과거만 남길지
  ) {
    final List<AttendanceStatus> adjustedList =
        List.from(list); // 복사 안 하면 인자로 받는 list가 바뀜
    if (makeFuture) {
      adjustedList.removeWhere(
          (element) => int.parse(element.date) < int.parse(localToday));
    } else {
      adjustedList.removeWhere(
          (element) => int.parse(element.date) >= int.parse(localToday));
    }
    return adjustedList;
  }
}

import '../common_instances.dart';
import 'html_util.dart';

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

  static Future<String> getCurrentSemester() async {
    late final String academicCalendarHtml;
    late String currentSemester;
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
        currentSemester = '${yearText - 1}-w';
      case Index.spring:
        currentSemester = '$yearText-1';
      case Index.summer:
        currentSemester = '$yearText-s';
      case Index.fall:
        currentSemester = '$yearText-2';
      case Index.winter:
        currentSemester = '$yearText-w';
    }

    return currentSemester;
  }
}

enum Index {
  lastWinter,
  spring,
  summer,
  fall,
  winter,
}

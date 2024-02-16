import 'package:html/parser.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';

class HtmlUtil {
  static List<String> getSemesterDuration(String html) {
    final monthSections = parse(html).querySelectorAll('.month-text');
    late final String firstSemesterStartDate;
    late final String firstSemesterEndDate;
    late final String secondSemesterStartDate;
    late final String secondSemesterEndDate;
    final List<String> semesterDuration = [];

    int calendarYear = DateUtil.getLocalNow().year;
    if (html.contains('${(calendarYear + 2).toString()}년')) calendarYear++;
    String yearText = calendarYear.toString();

    for (var monthSection in monthSections) {
      final march = monthSection.text.contains('3월');
      final june = monthSection.text.contains('6월');
      final september = monthSection.text.contains('9월');
      final december = monthSection.text.contains('12월');

      if (march || june || september || december) {
        final monthlyCalendar =
            monthSection.parent?.nextElementSibling?.querySelectorAll('.work');
        for (final work in monthlyCalendar!) {
          final day = work.querySelector('.day')?.text ?? '';
          final schedule = work.querySelector('.desc')?.text ?? '';

          if (march && schedule.contains('개강')) {
            firstSemesterStartDate = '$yearText/03/$day';
            break;
          } else if (june && schedule.contains('종강')) {
            firstSemesterEndDate = '$yearText/06/$day';
            break;
          } else if (september && schedule.contains('개강')) {
            secondSemesterStartDate = '$yearText/09/$day';
            break;
          } else if (december && schedule.contains('종강')) {
            secondSemesterEndDate = '$yearText/12/$day';
            break;
          }
        }
      }
    }

    semesterDuration.addAll([
      firstSemesterStartDate,
      firstSemesterEndDate,
      secondSemesterStartDate,
      secondSemesterEndDate,
    ]);

    return semesterDuration;
  }
}

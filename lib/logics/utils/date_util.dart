class DateUtil extends DateTime {
  DateUtil(super.year);
  static DateTime getLocalNow() {
    return DateTime.now().add(const Duration(hours: 9)); // Korea Time : UTC+9
  }

  static String getLocalToday() {
    final now = DateUtil.getLocalNow();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');

    return month + day;
  }

  static List<DateTime> getMeetingTimeList(
      DateTime start, DateTime end, int dayOfWeek, int hour) {
    List<DateTime> meetingTimeList = [];

    DateTime current = start;
    while (current.isBefore(end)) {
      DateTime meetingTime =
          DateTime(current.year, current.month, current.day, hour, 0, 0);
      meetingTimeList.add(meetingTime);
      current = current.add(const Duration(days: 7));
    }

    return meetingTimeList;
  }
}

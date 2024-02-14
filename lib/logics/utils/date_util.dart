class DateUtil extends DateTime {
  DateUtil(super.year);

  static DateTime getLocalNow() {
    return DateTime.now().add(const Duration(hours: 9)); // Korea Time : UTC+9
  }
}

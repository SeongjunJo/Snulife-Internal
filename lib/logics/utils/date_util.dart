class LocalDateTime extends DateTime {
  LocalDateTime(super.year);

  static DateTime now() {
    return DateTime.now().add(const Duration(hours: 9));
  }
}

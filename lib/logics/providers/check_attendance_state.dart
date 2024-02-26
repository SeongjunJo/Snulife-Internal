import 'package:flutter/material.dart';

class CheckAttendanceState extends ChangeNotifier {
  CheckAttendanceState({required this.userList}) {
    initUserAttendanceStatus();
  }

  final List<dynamic> userList;
  final Map<String, List<dynamic>> _userAttendanceStatus = {};
  Map<String, List<dynamic>> get userAttendanceStatus => _userAttendanceStatus;
  // {'홍길동': ['지각', false]} = 무단 지각
  bool _hasUpdated = false;
  bool get hasUpdated => _hasUpdated;

  initUserAttendanceStatus() {
    for (final user in userList) {
      _userAttendanceStatus[user] = ['', false];
    }
  }

  updateUserAttendanceStatus(
      String name, String? status, bool isAuthorized, bool hasUserModified) {
    if (status != null) _userAttendanceStatus[name]!.first = status;
    _userAttendanceStatus[name]!.last = isAuthorized;
    hasUserModified ? _hasUpdated = true : null;
    notifyListeners();
  }

  void setHasUpdated(bool value) {
    _hasUpdated = value;
    notifyListeners();
  }
}

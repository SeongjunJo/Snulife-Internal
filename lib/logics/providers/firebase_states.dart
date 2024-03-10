import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../common_instances.dart';

class FirebaseStates extends ChangeNotifier {
  FirebaseStates() {
    _init();
  }

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  bool _isManager = false;
  bool get isManager => _isManager;

  bool _isLeader = false;
  bool get isLeader => _isLeader;

  late String _currentSemester;
  String get currentSemester => _currentSemester;
  late String? _upcomingSemester;
  String? get upcomingSemester => _upcomingSemester;

  late Map? _userInfo; // 유저가 (부)대표인지 확인하는 과정에서 필요
  Map? get userInfo => _userInfo; // 기왕 받는 김에 홈화면에 넘겨줌
  String _clerk = '';
  String get clerk => _clerk;

  late String _thisWeekClerkDate;
  String get thisWeekClerkDate => _thisWeekClerkDate;

  Future<void> _init() async {
    FirebaseAuth.instance.userChanges().listen((User? user) async {
      if (user != null) {
        _loggedIn = true;
        await firebaseInstance.db // 유저가 (부)대표인지 확인
            .collection('users')
            .doc(firebaseInstance.userId)
            .get()
            .then((value) => _userInfo = value.data());
        _userInfo!['position'].contains('대표')
            ? _isManager = true
            : _isManager = false;
        _userInfo!['position'] == '팀장' ? _isLeader = true : _isLeader = false;

        final semesters =
            await firestoreReader.getCurrentAndUpcomingSemesters(); // 학기 fetch
        _currentSemester = semesters[0];
        _upcomingSemester = semesters.length > 1 ? semesters[1] : null;

        _thisWeekClerkDate = await firestoreReader.findClerkDate(
            _currentSemester, _upcomingSemester);

        firestoreReader
            .getPeopleAttendanceAndClerkStream(
                _currentSemester, _thisWeekClerkDate)
            .listen((doc) {
          _clerk = doc.data()!['clerk'];
          notifyListeners();
          if (_clerk.isEmpty) _clerk = '(미정)';
        });
      } else {
        _loggedIn = false;
        _userInfo = null;
        _clerk = '';
      }
      notifyListeners();
    });
  }
}

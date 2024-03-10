import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

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

  late final String _thisWeekClerkDate;

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

        _thisWeekClerkDate = await _findClerkDate();

        firestoreReader
            .getPeopleAttendanceAndClerkStream(
                _currentSemester, _thisWeekClerkDate)
            .listen((doc) {
          _clerk = doc.data()!['clerk'];
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

  Future _findClerkDate() async {
    final today = StringUtil.convertDateTimeToString(DateTime.now(), true);

    final meetingDatesQuery = await firebaseInstance.db
        .collection('attendances')
        .doc(_currentSemester)
        .collection('dates')
        .get();

    for (final date in meetingDatesQuery.docs) {
      // 다음 회의 문서 찾기
      if (int.parse(date.id) >= int.parse(today)) return date.id;
    }
    // 분기가 바뀌어서 return 못했으면 다음 학기의 첫 회의 문서 찾기
    final nextMeetingDatesQuery = await firebaseInstance.db
        .collection('attendances')
        .doc(_upcomingSemester)
        .collection('dates')
        .get();
    return nextMeetingDatesQuery.docs.first.id;
  }
}

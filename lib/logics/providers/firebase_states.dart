import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../common_instances.dart';

class FirebaseStates extends ChangeNotifier {
  FirebaseStates() {
    _init();
  }

  bool _isInternetConnected = true;
  bool get isInternetConnected => _isInternetConnected;
  set isInternetConnected(bool newValue) {
    if (_isInternetConnected != newValue) {
      _isReconnected = newValue;
    }
    _isInternetConnected = newValue;
  }

  bool _isReconnected = false;
  bool get isReconnected => _isReconnected;

  StreamSubscription? _streamSubscription;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

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

  Map _userInfo = {}; // 유저가 (부)대표인지 확인하는 과정에서 필요
  Map get userInfo => _userInfo; // 기왕 받는 김에 홈화면에 넘겨줌
  String _clerk = '';
  String get clerk => _clerk;

  late String _thisWeekClerkDate;
  String get thisWeekClerkDate => _thisWeekClerkDate;

  Future<void> _init() async {
    final internetConnectionChecker = InternetConnectionChecker.createInstance(
      checkInterval: const Duration(seconds: 5),
      checkTimeout: const Duration(seconds: 5),
    );

    internetConnectionChecker.onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          _streamSubscription = _getStream();
        case InternetConnectionStatus.disconnected:
          _streamSubscription?.cancel();
      }
      _isReconnected = false;
      isInternetConnected = status == InternetConnectionStatus.connected;
      notifyListeners();
    });
  }

  StreamSubscription _getStream() =>
      FirebaseAuth.instance.userChanges().listen((User? user) async {
        if (user != null) {
          await firebaseInstance.db // 유저가 (부)대표인지 확인
              .collection('users')
              .doc(firebaseInstance.userId)
              .get()
              .then((value) => _userInfo = value.data()!);
          _userInfo['position'].contains('대표')
              ? _isManager = true
              : _isManager = false;
          _userInfo['position'] == '팀장' ? _isLeader = true : _isLeader = false;

          final semesters = await firestoreReader
              .getCurrentAndUpcomingSemesters(); // 학기 fetch
          _currentSemester = semesters[0];
          _upcomingSemester = semesters.length > 1 ? semesters[1] : null;

          _thisWeekClerkDate = await firestoreReader.findClerkDate(
              _currentSemester, _upcomingSemester);

          firestoreReader
              .getPeopleAttendanceAndClerkStream(
                  _currentSemester, _thisWeekClerkDate)
              .listen((doc) {
            _clerk = doc.data()!['clerk'];
            if (_clerk.isEmpty) _clerk = '(미정)';
            _loggedIn = true;
            _isLoading = false;
            notifyListeners();
          });
        } else {
          _loggedIn = false;
          _isLoading = false;
          _userInfo = {};
          _clerk = '';
        }
        notifyListeners();
      });
}

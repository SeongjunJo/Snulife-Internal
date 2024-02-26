import 'package:flutter/material.dart';

class AppTab {
  static late TabController attendanceTabController;
  static late TabController myAttendanceTabController;
  static late TabController managementTabController;

  static const List<Tab> attendanceTabs = <Tab>[
    Tab(text: '출석 체크'),
    Tab(text: '서기'),
  ];

  static const List<Tab> myAttendanceTabs = <Tab>[
    Tab(text: '지각/결석'),
    Tab(text: '출결 현황'),
  ];

  static const List<Tab> managementTabs = <Tab>[
    Tab(text: 'QS 관리'),
    Tab(text: '회의 관리'),
  ];
}

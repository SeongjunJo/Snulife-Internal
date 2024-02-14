import 'package:flutter/material.dart';

class AppTab {
  static late TabController attendanceTabController;
  static late TabController myAttendanceTabController;

  static List<Tab> attendanceTabs = <Tab>[
    const Tab(text: '출석 체크'),
    const Tab(text: '서기'),
  ];

  static List<Tab> myAttendanceTabs = <Tab>[
    const Tab(text: '지각/결석'),
    const Tab(text: '출결 현황'),
  ];
}

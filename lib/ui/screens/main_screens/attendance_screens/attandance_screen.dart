import 'package:flutter/material.dart';
import 'package:snulife_internal/ui/screens/main_screens/attendance_screens/check_attendance_screen.dart';
import 'package:snulife_internal/ui/screens/main_screens/attendance_screens/clerk_screen.dart';

import '../../../widgets/commons/app_tabs.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  Widget build(BuildContext context) {
    return TabBarView(
        controller: AppTab.attendanceTabController,
        children: AppTab.attendanceTabs.map((Tab tab) {
          return tab.text! == '출석 체크'
              ? const CheckAttendancePage()
              : const ClerkPage();
        }).toList());
  }
}

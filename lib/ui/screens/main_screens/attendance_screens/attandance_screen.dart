import 'package:flutter/material.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';
import 'check_attendance_screen.dart';
import 'clerk_screen.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        controller: AppTab.attendanceTabController,
        children: AppTab.attendanceTabs.map((Tab tab) {
          // 별도 Widget으로 분리하면 memoizer로 캐싱할 수 없음

          return tab.text! == '출석 체크'
              ? FutureBuilder(
                  future: firestoreReader.getUserList(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return CheckAttendancePage(userList: snapshot.data);
                    } else {
                      return Container(color: appColors.grey0);
                    }
                  },
                )
              : FutureBuilder(
                  future: firestoreReader.getClerkMap(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return ClerkPage(clerkMap: snapshot.data);
                    } else {
                      return Container(color: appColors.grey0);
                    }
                  },
                );
        }).toList());
  }
}

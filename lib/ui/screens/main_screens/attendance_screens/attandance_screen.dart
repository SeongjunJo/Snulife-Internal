import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/firebase_states.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';
import 'check_attendance_screen.dart';
import 'clerk_screen.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key, required this.currentSemester});

  final String currentSemester;

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
                      return CheckAttendancePage(
                        userList: snapshot.data,
                        currentSemester: currentSemester,
                      );
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
                      return Consumer<FirebaseStates>(
                        builder: (context, value, _) => ClerkPage(
                          isManager: value.isManager,
                          clerk: value.clerk,
                          clerkMap: snapshot.data,
                          currentSemester: value.currentSemester,
                          upcomingSemester: value.upcomingSemester,
                        ),
                      );
                    } else {
                      return Container(color: appColors.grey0);
                    }
                  },
                );
        }).toList());
  }
}

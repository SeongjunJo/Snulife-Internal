import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/check_attendance_state.dart';
import 'package:snulife_internal/logics/providers/firebase_states.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';
import '../../../../logics/utils/map_util.dart';
import 'check_attendance_screen.dart';
import 'clerk_screen.dart';
import 'no_meeting_today_screen.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({
    super.key,
    required this.currentSemester,
    required this.clerk,
    required this.isLeader,
  });

  final String currentSemester;
  final String clerk;
  final bool isLeader;

  @override
  Widget build(BuildContext context) {
    final bool isClerk = firebaseInstance.userName == clerk;

    return TabBarView(
        controller: AppTab.attendanceTabController,
        children: AppTab.attendanceTabs.map((Tab tab) {
          // 별도 Widget으로 분리하면 memoizer로 캐싱할 수 없음

          return tab.text! == '출석 체크'
              ? FutureBuilder(
                  future: _getIsTodayMeeting(currentSemester),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return !snapshot.data // 오늘 회의가 없으면 디폴트 화면
                          ? const NoMeetingTodayPage()
                          : FutureBuilder(
                              future: Future.wait([
                                firestoreReader.getUserList(),
                                firestoreReader.checkHasMeetingStarted(),
                                _getTeamMeetingTime(),
                              ]),
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.hasData) {
                                  bool isTeamMeeting = snapshot.data[2]
                                      .cast<String>()
                                      .contains(localToday);

                                  return ChangeNotifierProvider(
                                    create: (context) => CheckAttendanceState(
                                        userList: snapshot.data[0]),
                                    builder: ((context, _) =>
                                        CheckAttendancePage(
                                          isClerk: isClerk,
                                          // 팀별 회의 때는 팀장들이 출석 체크
                                          doesLeaderCheck:
                                              isLeader && isTeamMeeting,
                                          hasMeetingStarted: snapshot.data[1],
                                          userList: snapshot.data[0],
                                          currentSemester: currentSemester,
                                        )),
                                  );
                                } else {
                                  return Container(color: appColors.grey0);
                                }
                              },
                            );
                    } else {
                      return Container(color: appColors.grey0);
                    }
                  },
                )
              : FutureBuilder(
                  future: _getClerkMap(),
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

Future _getClerkMap() async => memoizer.runOnce(() async {
      final clerkCollection =
          await firebaseInstance.db.collection('clerks').get();
      return MapUtil.orderClerksByCount(clerkCollection);
    });

Future _getIsTodayMeeting(String currentSemester) async =>
    memoizer.runOnce(() async {
      final doc = await firebaseInstance.db
          .collection('attendances')
          .doc(currentSemester)
          .collection('dates')
          // TODO localToday로 바꾸기
          .doc('0229')
          .get();
      return doc.exists;
    });

Future _getTeamMeetingTime() async => memoizer.runOnce(() async {
      final doc = await firebaseInstance.db
          .collection('information')
          .doc('meetingTime')
          .get();
      return doc.data()!['teamMeeting'];
    });

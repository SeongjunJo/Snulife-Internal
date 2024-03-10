import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/check_attendance_state.dart';
import 'package:snulife_internal/logics/providers/firebase_states.dart';

import '../../../../logics/app_tabs.dart';
import '../../../../logics/common_instances.dart';
import '../../../../logics/utils/map_util.dart';
import '../../../../logics/utils/string_util.dart';
import 'check_attendance_screen.dart';
import 'clerk_screen.dart';
import 'no_meeting_today_screen.dart';

final today = StringUtil.convertDateTimeToString(DateTime.now(), true);

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

    return FutureBuilder(
      future: Future.wait([
        _getIsTodayMeeting(currentSemester),
        _getClerkMap(),
        // 아래 3개 future는 오늘이 회의일 때만 필요하지만, 사람들은 대부분 회의인 날만 이 화면에 접속할 것이므로
        // 미리 다 받아서 Tab 전환 랜더링 시간을 줄임
        firestoreReader.getUserList(),
        firestoreReader.checkHasMeetingStarted(),
        _getTeamMeetingTime(),
      ]),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          final isTodayMeeting = snapshot.data[0];
          final clerkMap = snapshot.data[1];
          final userList = snapshot.data[2];
          final hasMeetingStarted = snapshot.data[3];
          final isTeamMeeting = snapshot.data[4].cast<String>().contains(today);

          return TabBarView(
              controller: AppTab.attendanceTabController,
              children: AppTab.attendanceTabs.map((Tab tab) {
                return tab.text! == AppTab.attendanceTabs.first.text
                    ? !isTodayMeeting // 오늘 회의가 없으면 디폴트 화면
                        ? const NoMeetingTodayPage()
                        : ChangeNotifierProvider(
                            create: (context) =>
                                CheckAttendanceState(userList: userList),
                            builder: ((context, _) => CheckAttendancePage(
                                  isClerk: isClerk,
                                  // 팀별 회의 때는 팀장들이 출석 체크
                                  doesLeaderCheck: isLeader && isTeamMeeting,
                                  hasMeetingStarted: hasMeetingStarted,
                                  userList: userList,
                                  currentSemester: currentSemester,
                                )),
                          )
                    : Consumer<FirebaseStates>(
                        builder: (context, value, _) => ClerkPage(
                          isManager: value.isManager,
                          clerk: value.clerk,
                          clerkMap: clerkMap,
                          currentSemester: value.currentSemester,
                          upcomingSemester: value.upcomingSemester,
                        ),
                      );
              }).toList());
        } else {
          return Container(color: appColors.grey0);
        }
      },
    );
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
          // TODO today로 바꾸기
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

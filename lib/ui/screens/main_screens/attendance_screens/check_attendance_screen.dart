import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../../logics/common_instances.dart';
import '../../../../logics/providers/check_attendance_state.dart';
import '../../../../logics/utils/string_util.dart';
import '../../../widgets/commons/modal_widgets.dart';
import '../../../widgets/screen_specified/attendance_widget.dart';

class CheckAttendancePage extends StatelessWidget {
  const CheckAttendancePage({
    super.key,
    required this.isClerk,
    required this.doesLeaderCheck,
    required this.hasMeetingStarted,
    required this.currentSemester,
    required this.userList,
  });

  final bool isClerk;
  final bool doesLeaderCheck;
  final bool hasMeetingStarted;
  final String currentSemester;
  final List<dynamic> userList;

  @override
  Widget build(BuildContext context) {
    bool canModify =
        doesLeaderCheck ? true : isClerk; // 팀별 회의 때는 팀장만 체크 가능, 아니면 서기만 체크 가능

    final DateTime now = DateTime.now();
    final String today = StringUtil.convertDateTimeToString(now, true);
    final attendanceListener = context.watch<CheckAttendanceState>();
    bool unCompleted = false;

    for (final user in attendanceListener.userAttendanceStatus.keys) {
      if (attendanceListener.userAttendanceStatus[user]!.first == '') {
        unCompleted = true;
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: appColors.grey0,
      child: StreamBuilder(
        stream: firestoreReader.getPeopleAttendanceAndClerkStream(
            currentSemester, today),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: appColors.grey0,
              child: Center(
                child: CircularProgressIndicator(color: appColors.slBlue),
              ),
            );
          } else if (snapshot.hasData) {
            final attendanceStatus =
                snapshot.data!.data() as Map<String, dynamic>;
            bool hasAttendanceConfirmed =
                attendanceStatus['hasAttendanceConfirmed'];

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        "${now.month}월 ${now.day}일자 회의\n출석체크를 해주세요.",
                        style: appFonts.h1,
                      ),
                      const SizedBox(height: 40),
                      ListView.separated(
                        // 전체 위젯이 한번에 빌드되지만, 인원수가 많지 않고 index는 필요하므로 builder 사용
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: userList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CheckAttendanceListItem(
                            canModify: canModify &&
                                !hasAttendanceConfirmed &&
                                hasMeetingStarted, // 회의 시작 후, 서기이면서 확정하지 않은 상태만 수정 가능
                            name: userList[index],
                            attendanceStatus: attendanceStatus,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 8);
                        },
                      ),
                      const SizedBox(height: 24),
                      if (canModify && userList.length > 6)
                        // 하단 버튼이 sticky 하게 보이도록 함
                        Column(
                          children: [
                            const SizedBox(height: 32),
                            _buildButtons(
                              hasAttendanceConfirmed,
                              attendanceListener,
                              unCompleted,
                              context,
                            ),
                          ],
                        )
                    ],
                  ),
                ),
                if (canModify && userList.length <= 6)
                  _buildButtons(
                    hasAttendanceConfirmed,
                    attendanceListener,
                    unCompleted,
                    context,
                  ),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }

  Column _buildButtons(
      bool hasAttendanceConfirmed,
      CheckAttendanceState attendanceListener,
      bool unCompleted,
      BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            AppExpandedButton(
              buttonText: "저장",
              // 확정을 안 했고 수정 사항이 생길 때만 저장 가능
              onPressed:
                  !hasAttendanceConfirmed && attendanceListener.hasUpdated
                      ? () {
                          firestoreWriter.saveAttendanceStatus(
                            currentSemester,
                            attendanceListener.userAttendanceStatus,
                            false,
                          );
                          attendanceListener.setHasUpdated(false);
                        }
                      : null,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            AppExpandedButton(
              buttonText: "확정",
              // 확정을 안 했고, 출석 체크는 전부 했고, 저장도 한 경우만 확정 가능
              onPressed: !hasAttendanceConfirmed &&
                      !unCompleted &&
                      !attendanceListener.hasUpdated
                  ? () => showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                          title: "출석체크 내역을 확정하시겠어요?",
                          content: "확정 이후에는 출결을 변경할 수 없어요.\n꼭 회의가 끝난 뒤 확정해주세요.",
                          onPressed: () {
                            firestoreWriter.saveAttendanceStatus(
                                currentSemester,
                                attendanceListener.userAttendanceStatus,
                                true);
                            firestoreWriter.confirmAttendanceStatus(
                                currentSemester,
                                attendanceListener.userAttendanceStatus);
                            Navigator.pop(context);
                          },
                        ),
                        useRootNavigator: false, // 뒤로 가기 버튼이 제대로 먹히게
                      )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

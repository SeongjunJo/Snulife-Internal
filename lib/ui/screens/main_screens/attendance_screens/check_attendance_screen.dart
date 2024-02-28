import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

import '../../../../logics/common_instances.dart';
import '../../../../logics/providers/check_attendance_state.dart';
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

    final today = DateUtil.getLocalNow();
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
            // TODO 실제 날짜로 바꾸기
            currentSemester,
            '0215'),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            final attendanceStatus =
                snapshot.data!.data() as Map<String, dynamic>;
            bool hasAttendanceConfirmed =
                attendanceStatus['hasAttendanceConfirmed'];

            return ListView(
              children: [
                const SizedBox(height: 32),
                Text(
                  "${today.month}월 ${today.day}일자 회의\n출석체크를 해주세요.",
                  style: appFonts.h1,
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.separated(
                    // 전체 위젯이 한번에 빌드되지만, 인원수가 많지 않고 index는 필요하므로 builder 사용
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: userList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return AttendanceListItem(
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
                ),
                canModify
                    ? const SizedBox(height: 70)
                    : const SizedBox(), // ListView 때문에 Column으로 못 함
                canModify
                    ? AppExpandedButton(
                        buttonText: "저장하기",
                        // 확정을 안 했고 수정 사항이 생길 때만 저장 가능
                        onPressed: !hasAttendanceConfirmed &&
                                attendanceListener.hasUpdated
                            ? () {
                                firestoreWriter.saveAttendanceStatus(
                                  currentSemester,
                                  attendanceListener.userAttendanceStatus,
                                  false,
                                );
                                attendanceListener.setHasUpdated(false);
                              }
                            : null,
                      )
                    : const SizedBox(),
                canModify ? const SizedBox(height: 20) : const SizedBox(),
                canModify
                    ? AppExpandedButton(
                        buttonText: "확정하기",
                        // 확정을 안 했고, 출석 체크는 전부 했고, 저장도 한 경우만 확정 가능
                        onPressed: !hasAttendanceConfirmed &&
                                !unCompleted &&
                                !attendanceListener.hasUpdated
                            ? () => showDialog(
                                  context: context,
                                  builder: (context) => ConfirmDialog(
                                    title: "출석체크 내역을 확정하시겠어요?",
                                    content:
                                        "확정 이후에는 출결을 변경할 수 없어요.\n꼭 회의가 끝난 뒤 확정해주세요.",
                                    onPressed: () {
                                      firestoreWriter.saveAttendanceStatus(
                                          currentSemester,
                                          attendanceListener
                                              .userAttendanceStatus,
                                          true);
                                      firestoreWriter.confirmAttendanceStatus(
                                          currentSemester,
                                          attendanceListener
                                              .userAttendanceStatus);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  useRootNavigator: false, // 뒤로 가기 버튼이 제대로 먹히게
                                )
                            : null,
                      )
                    : const SizedBox(),
                const SizedBox(height: 40),
              ],
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}

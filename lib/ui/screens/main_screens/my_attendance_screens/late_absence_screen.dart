import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/screen_specified/my_attendance_widget.dart';

int? _modalIndex; // 모달의 결석/지각 체크 박스 인덱스: null이면 선택 안 함, 1이면 결석, 2면 지각
List<int> _selectedIndexes = [];
List<AttendanceStatus> _lateAbsenceList = [];
bool? _isLate; // null이면 선택 안 함, true면 지각, false면 결석

class LateAbsencePage extends StatefulWidget {
  const LateAbsencePage({
    super.key,
    required this.currentSemester,
    required this.upcomingSemester,
  });

  final String currentSemester;
  final String? upcomingSemester;

  @override
  State<LateAbsencePage> createState() => _LateAbsencePageState();
}

class _LateAbsencePageState extends State<LateAbsencePage> {
  late final StreamSubscription currentSemesterStatusListener;
  late final StreamSubscription? upcomingSemesterStatusListener;

  final List<AttendanceStatus> currentSemesterStatus = [];
  final List<AttendanceStatus> upcomingSemesterStatus = [];

  @override
  void initState() {
    super.initState();
    currentSemesterStatusListener = firestoreReader
        .getMyAttendanceStatusListener(widget.currentSemester, () {
      setState(() {});
    }, currentSemesterStatus);
    upcomingSemesterStatusListener = widget.upcomingSemester != null
        ? firestoreReader
            .getMyAttendanceStatusListener(widget.upcomingSemester!, () {
            setState(() {});
          }, upcomingSemesterStatus)
        : null;
  }

  @override
  void dispose() {
    super.dispose();
    _selectedIndexes.clear();
    _lateAbsenceList.clear();
    currentSemesterStatusListener.cancel();
    upcomingSemesterStatusListener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    int currentSemesterWeek = currentSemesterStatus.length;
    List<AttendanceStatus> adjustedCurrentSemesterStatus =
        StringUtil.adjustListWithDate(currentSemesterStatus, true); // 미래만 남김
    int indexOffset = adjustedCurrentSemesterStatus.length;
    List<AttendanceStatus> semesterStatus =
        adjustedCurrentSemesterStatus + upcomingSemesterStatus;

    return FutureBuilder(
      future: memoizer.runOnce(() => firebaseInstance.db
          .collection('informations')
          .doc('meetingTime')
          .get()),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        // snapshot : 회의 일자, 휴외 일자, 회의 시간 보유
        if (snapshot.hasData) {
          final String meetingTime = snapshot.data.data()['time'];
          final List<String> meetingRestDates =
              snapshot.data.data()['rest'].cast<String>();

          return Container(
            color: appColors.grey0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: appColors.grey1,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Text(
                    "지각 신청은 회의 시작 전까지,\n결석 신청은 전날 자정까지 가능해요.",
                    style: appFonts.c3.copyWith(color: appColors.grey6),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: semesterStatus.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isRestDate =
                          meetingRestDates.contains(semesterStatus[index].date);

                      return GestureDetector(
                        onTap: (semesterStatus[index].attendance == "" &&
                                !isRestDate)
                            ? () {
                                setState(() {
                                  if (_selectedIndexes.contains(index)) {
                                    _lateAbsenceList
                                        .remove(semesterStatus[index]);
                                    _selectedIndexes.remove(index);
                                  } else {
                                    _lateAbsenceList.add(semesterStatus[index]);
                                    _selectedIndexes.add(index);
                                  }
                                });
                              }
                            : null, // 지각/결석 신청했거나 휴회일이면 선택 불가
                        child: MyAttendanceListItem(
                          week: (index + 1 > indexOffset)
                              ? index + 1 - indexOffset
                              : currentSemesterWeek + index,
                          date: semesterStatus[index].date,
                          isSelected: _selectedIndexes.contains(index),
                          lateOrAbsence: !isRestDate
                              ? semesterStatus[index].attendance
                              : "휴회", // 지각/결석/휴회가 아니라면 빈 문자열이 넘어감
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8);
                    },
                  ),
                ),
                const SizedBox(height: 37),
                AppExpandedButton(
                  buttonText: "신청",
                  onPressed: _selectedIndexes.isNotEmpty
                      ? () {
                          _modalIndex = null;
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return _BottomModal(
                                currentSemester: widget.currentSemester,
                                upcomingSemester: widget.upcomingSemester,
                                meetingTime: meetingTime,
                                setState: () {
                                  setState(() {});
                                },
                              );
                            },
                          );
                        }
                      : null,
                ),
                const SizedBox(height: 62),
              ],
            ),
          );
        } else {
          return Container(color: appColors.grey0);
        }
      },
    );
  }
}

class _BottomModal extends StatefulWidget {
  const _BottomModal({
    required this.currentSemester,
    required this.upcomingSemester,
    required this.meetingTime,
    required this.setState,
  });

  final String currentSemester;
  final String? upcomingSemester;
  final String meetingTime;
  final Function setState;

  @override
  State<_BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<_BottomModal> {
  final now = DateUtil.getLocalNow();
  late final hour = now.hour.toString().padLeft(2, '0');
  late final minute = now.minute.toString().padLeft(2, '0');
  late final currentTime = hour + minute;

  @override
  void initState() {
    super.initState();
    _isLate = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 360,
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 22),
              Text("지각/결석 여부를 선택해주세요.", style: appFonts.h3),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _modalIndex = 0;
                    _isLate = false;
                  });
                },
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("결석",
                          style: appFonts.h3.copyWith(color: appColors.grey8)),
                      Image.asset(
                        "assets/images/icon_check.png",
                        color: _modalIndex == 0
                            ? appColors.slBlue
                            : appColors.grey3,
                        width: 34,
                        height: 34,
                      ),
                    ],
                  ),
                ),
              ),
              Container(height: 1, color: appColors.grey3),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _modalIndex = 1;
                    _isLate = true;
                  });
                },
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("지각",
                          style: appFonts.h3.copyWith(color: appColors.grey8)),
                      Image.asset(
                        "assets/images/icon_check.png",
                        color: _modalIndex == 1
                            ? appColors.slBlue
                            : appColors.grey3,
                        width: 34,
                        height: 34,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                '신청 후에는 서기만 출결 변경이 가능해요.',
                style: appFonts.c3.copyWith(color: appColors.grey5),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppExpandedButton(
                    buttonText: '취소',
                    onPressed: () {
                      context.pop();
                    },
                    isCancelButton: true,
                  ),
                  const SizedBox(width: 8),
                  AppExpandedButton(
                    buttonText: '확정',
                    onPressed: _isLate != null
                        ? () async {
                            if (_lateAbsenceList
                                .any((element) => element.date == localToday)) {
                              if (_isLate!) {
                                // 회의 시간 넘기면 지각 신청 불가
                                int.parse(currentTime) >=
                                        int.parse(widget.meetingTime)
                                    ? ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                        SnackBar(
                                          content: Center(
                                            child: Text(
                                              "회의 시작 후에는 지각 신청을 할 수 없어요.",
                                              style: appFonts.b2.copyWith(
                                                color: appColors.white,
                                              ),
                                            ),
                                          ),
                                          backgroundColor: appColors.slBlue,
                                        ),
                                      )
                                    : null;
                              } else {
                                // 회의 날짜 넘기면 결석 신청 불가
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(
                                      child: Text(
                                        "회의 당일에는 결석 신청을 할 수 없어요.",
                                        style: appFonts.b2.copyWith(
                                          color: appColors.white,
                                        ),
                                      ),
                                    ),
                                    backgroundColor: appColors.slBlue,
                                  ),
                                );
                              }
                            } else {
                              await firestoreWriter.writeMyLateAbsence(
                                  widget.currentSemester,
                                  _lateAbsenceList,
                                  _isLate!);
                              widget.upcomingSemester != null
                                  ? await firestoreWriter.writeMyLateAbsence(
                                      widget.upcomingSemester!,
                                      _lateAbsenceList,
                                      _isLate!)
                                  : null;
                            }
                            _selectedIndexes.clear();
                            _lateAbsenceList.clear();
                            widget.setState();
                            if (!mounted) return;
                            context.pop();
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

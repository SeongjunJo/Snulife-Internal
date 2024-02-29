import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/logics/utils/date_util.dart';
import 'package:snulife_internal/logics/utils/map_util.dart';
import 'package:snulife_internal/logics/utils/string_util.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/commons/button_widgets.dart';
import '../../../widgets/commons/modal_widgets.dart';
import '../../../widgets/screen_specified/my_attendance_widget.dart';

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
  final List<int> _selectedIndexes = [];
  final List<AttendanceStatus> _lateAbsenceList = [];
  final ValueNotifier<bool?> _isLate =
      ValueNotifier(null); // null이면 선택 안 함, true면 지각, false면 결석

  late final StreamSubscription _currentSemesterStatusListener;
  late final StreamSubscription? _upcomingSemesterStatusListener;

  final List<AttendanceStatus> _currentSemesterStatus = [];
  final List<AttendanceStatus> _upcomingSemesterStatus = [];

  @override
  void initState() {
    super.initState();
    _currentSemesterStatusListener = firestoreReader
        .getMyAttendanceStatusListener(widget.currentSemester, () {
      setState(() {});
    }, _currentSemesterStatus);
    _upcomingSemesterStatusListener = widget.upcomingSemester != null
        ? firestoreReader
            .getMyAttendanceStatusListener(widget.upcomingSemester!, () {
            setState(() {});
          }, _upcomingSemesterStatus)
        : null;
  }

  @override
  void dispose() {
    super.dispose();
    _currentSemesterStatusListener.cancel();
    _upcomingSemesterStatusListener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    int currentSemesterWeek = _currentSemesterStatus.length;
    List<AttendanceStatus> adjustedCurrentSemesterStatus =
        StringUtil.adjustListWithDate(_currentSemesterStatus, true); // 오늘 이후 남김
    int indexOffset = adjustedCurrentSemesterStatus.length;
    List<AttendanceStatus> semesterStatus =
        adjustedCurrentSemesterStatus + _upcomingSemesterStatus;

    return FutureBuilder(
      future: memoizer.runOnce(() => firebaseInstance.db
          .collection('information')
          .doc('meetingTime')
          .get()),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                              : "휴회", // 지각/결석/휴회가 아니라면 (= 특수 상황 아니면) 빈 문자열이 넘어감
                          isReadOnly: false,
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
                          _isLate.value = null;
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return ValueListenableBuilder<bool?>(
                                valueListenable: _isLate,
                                builder: (context, bool? value, _) {
                                  return BottomModal(
                                      onFirstTap: () => _isLate.value = false,
                                      onSecondTap: () => _isLate.value = true,
                                      onPressed: _isLate.value != null
                                          ? () => _onPressed(meetingTime)
                                          : null);
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

  // 함수가 길고, 직접 넣으면 들여쓰기로 포맷팅이 과해져서 따로 뺌
  _onPressed(String meetingTime) async {
    final now = DateUtil.getLocalNow();
    late final currentTime = StringUtil.convertDateTimeToString(now, false);

    if (_lateAbsenceList.any((element) => element.date == localToday)) {
      // 오늘 날짜를 선택했을 때 핸들링
      if (_isLate.value!) {
        // 회의 시간 넘기면 지각 신청 불가
        int.parse(currentTime) >= int.parse(meetingTime)
            ? ScaffoldMessenger.of(context).showSnackBar(
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
          widget.currentSemester, _lateAbsenceList, _isLate.value!);
      widget.upcomingSemester != null
          ? await firestoreWriter.writeMyLateAbsence(
              widget.upcomingSemester!, _lateAbsenceList, _isLate.value!)
          : null;
    }
    _selectedIndexes.clear();
    _lateAbsenceList.clear();
    setState(() {});
    if (!mounted) return;
    context.pop();
  }
}

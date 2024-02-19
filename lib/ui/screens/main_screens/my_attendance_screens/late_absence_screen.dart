import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/widgets/screen_specified/my_attendance_widget.dart';

import '../../../../logics/common_instances.dart';
import '../../../widgets/commons/button_widgets.dart';

int? _modalIndex;
List<int> _selectedIndexes = [];

class LateAbsencePage extends StatefulWidget {
  const LateAbsencePage({super.key, required this.upcomingAttendanceStatus});

  final List<dynamic> upcomingAttendanceStatus;

  @override
  State<LateAbsencePage> createState() => _LateAbsencePageState();
}

class _LateAbsencePageState extends State<LateAbsencePage> {
  final now = DateTime.now();
  late final month = now.month.toString().padLeft(2, '0');
  late final day = now.day.toString().padLeft(2, '0');
  late final today = month + day;

  late final currentSemester = widget.upcomingAttendanceStatus[0];
  late final upcomingSemester = widget.upcomingAttendanceStatus[1];
  late final currentSemesterStatus = widget.upcomingAttendanceStatus[2]
      .where((element) => int.parse(element.date) >= int.parse(today))
      .toList(); // 오늘 이후의 출결 상태
  late final upcomingSemesterStatus =
      widget.upcomingAttendanceStatus[3]; // 다음 학기 출결 상태
  late final indexOffset = currentSemesterStatus.length;
  late final upcomingAttendanceStatus =
      currentSemesterStatus + upcomingSemesterStatus;

  late final StreamSubscription currentSemesterStatusListener;
  late final StreamSubscription? upcomingSemesterStatusListener;

  @override
  void initState() {
    super.initState();
    currentSemesterStatusListener =
        firestoreReader.getMyAttendanceStatusListener(currentSemester, () {
      setState(() {});
    });
    upcomingSemesterStatusListener = upcomingSemesterStatus != null
        ? firestoreReader.getMyAttendanceStatusListener(upcomingSemester, () {
            setState(() {});
          })
        : null;
  }

  @override
  void dispose() {
    super.dispose();
    currentSemesterStatusListener.cancel();
    upcomingSemesterStatusListener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
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
              itemCount: 2,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  // TODO 지각/결석 예정이면 onTap 없애기
                  onTap: () {
                    setState(() {
                      if (_selectedIndexes.contains(index)) {
                        _selectedIndexes.remove(index);
                      } else {
                        _selectedIndexes.add(index);
                      }
                    });
                  },
                  child: MyAttendanceListItem(
                    week: 4,
                    date: '02/15',
                    isSelected: _selectedIndexes.contains(index),
                    lateOrAbsence: '', // 지각/결석이 아니라면 빈 문자열이 넘어감
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
            onPressed: () {
              _modalIndex = null;
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return const _BottomModal();
                },
              );
            },
          ),
          const SizedBox(height: 62),
        ],
      ),
    );
  }
}

class _BottomModal extends StatefulWidget {
  const _BottomModal();

  @override
  State<_BottomModal> createState() => _BottomModalState();
}

class _BottomModalState extends State<_BottomModal> {
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
                    onPressed: () => context.pop(),
                    isCancelButton: true,
                  ),
                  const SizedBox(width: 8),
                  AppExpandedButton(
                    buttonText: '확정',
                    onPressed: () {
                      _selectedIndexes.clear();
                      // TODO 서버에 신청이 완료된 후에 pop
                      // TODO => 즉, 비동기 함수안으로 pop을 옮겨야 함 (onPressed는 함수를 기다리지 않음)
                      // TODO => 서버에 쓰는 건 기다리고, 서버에서 다시 받아오는 걸 콜만 한 뒤 바로 pop
                      // TODO => 그럼 pop 되고 난 후 서버에서 값을 받아와서 화면이 rebuild 됨
                      context.pop();
                    },
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

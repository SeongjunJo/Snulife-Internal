import 'package:flutter/material.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

class MyAttendanceListItem extends StatelessWidget {
  const MyAttendanceListItem({
    super.key,
    required this.week,
    required this.date,
    required this.isSelected,
    required this.lateOrAbsence,
    this.isReadOnly = false,
  });

  final int week;
  final String date;
  final bool isSelected;
  final String lateOrAbsence;
  final bool isReadOnly;
  // true: 출결 현황 화면 / false: 지각, 결석 신청 화면
  @override
  Widget build(BuildContext context) {
    AttendanceChipType chipType;
    switch (lateOrAbsence) {
      case '지각':
        chipType = AttendanceChipType.late;
      case '결석':
        chipType = AttendanceChipType.absence;
      default: // 출석 or 휴회; 휴회인 경우는 chip 없이 text만 표시됨 (지각/결석 화면)
        chipType = AttendanceChipType.presence;
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: isReadOnly || lateOrAbsence.isEmpty
            ? appColors.white
            : appColors.grey3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? appColors.slBlue : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '정기회의 $week주차',
                style: appFonts.c3.copyWith(color: appColors.grey6),
              ),
              Text(
                '${date.substring(0, 2)}/${date.substring(2, 4)}',
                style: appFonts.h3.copyWith(
                    color: isReadOnly || lateOrAbsence.isEmpty
                        ? appColors.grey8
                        : appColors.grey6),
              ),
            ],
          ),
          isReadOnly
              ? AttendanceChip(
                  index: null, // index 불필요
                  type: chipType,
                  onSelected: (_) {}, // null 대신 chip 색깔 보정
                  isSelected: true, // 항상 색이 들어온 상태
                )
              : lateOrAbsence.isEmpty
                  ? Image.asset(
                      'assets/images/icon_check.png',
                      color: isSelected ? appColors.slBlue : appColors.grey3,
                      width: 34,
                      height: 34,
                    )
                  : Text(
                      lateOrAbsence == '휴회'
                          ? lateOrAbsence
                          : '$lateOrAbsence 예정',
                      style: appFonts.t4.copyWith(color: appColors.grey6),
                    ),
        ],
      ),
    );
  }
}

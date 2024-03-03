import 'package:flutter/material.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

class MyAttendanceListItem extends StatelessWidget {
  const MyAttendanceListItem({
    super.key,
    required this.week,
    required this.date,
    required this.isSelected,
    required this.status,
    this.isAuthorized, // 출결 현황에서만 bool
    this.isReadOnly = false, // 출결 현황에서만 true
  });

  final int week;
  final String date;
  final bool isSelected;
  final String status;
  final bool? isAuthorized;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    AttendanceChipType chipType;
    switch (status) {
      case '지각':
        chipType = AttendanceChipType.late;
      case '결석':
        chipType = AttendanceChipType.absence;
      default: // 출석 or 휴회 or 팀별 회의; 출석 이외는 chip 없이 text만 표시됨
        chipType = AttendanceChipType.presence;
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: (isReadOnly || status != '지각' && status != '결석') // 신청 완료하면 회색
            ? appColors.white
            : appColors.grey2,
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
                style: appFonts.c3.copyWith(
                    color: (status == '휴회' || status == '팀별 회의')
                        ? appColors.grey4
                        : // 휴회/팀별 회의면 옅은 회색
                        (isReadOnly || status.isEmpty)
                            ? appColors.grey6 // 신청 전 짙은 회색
                            : appColors.grey5), // 신청 완료하면 회색
              ),
              Text(
                '${date.substring(0, 2)}/${date.substring(2, 4)}',
                style: appFonts.h3.copyWith(
                    color: (status == '휴회' || status == '팀별 회의')
                        ? appColors.grey4
                        : // 휴회/팀별 회의면 옅은 회색
                        (isReadOnly || status.isEmpty)
                            ? appColors.grey8 // 신청 전 검은색
                            : appColors.grey5), // 신청 완료하면 회색
              ),
            ],
          ),
          if (isReadOnly) // 출결 현황 화면
            if (status != '휴회') // 출석/지각/결석 chip
              Row(
                children: [
                  status == '지각' || status == '결석'
                      ? AppStatusTag(
                          title: Text(isAuthorized! ? '사유' : '무단'),
                          isTurnedOn: isAuthorized!,
                          onPressed: () {},
                        )
                      : const SizedBox(),
                  status == '지각' || status == '결석'
                      ? const SizedBox(width: 12)
                      : const SizedBox(),
                  AttendanceChip(
                    index: null, // index 불필요
                    type: chipType,
                    onSelected: (_) {}, // null 대신 chip 색깔 보정
                    isSelected: true, // 항상 색이 들어온 상태
                  ),
                ],
              )
            else // 휴회 텍스트
              SizedBox(
                width: 56,
                child: Center(
                  child: Text(
                    '휴회',
                    style: appFonts.t4.copyWith(color: appColors.grey4),
                  ),
                ),
              )
          else if (status.isEmpty) // 지각/결석 화면 체크박스
            Image.asset(
              'assets/images/icon_check.png',
              color: isSelected ? appColors.slBlue : appColors.grey3,
              width: 34,
              height: 34,
            )
          else // 지각/결석 화면 휴회 텍스트
            Text(
              (status == '휴회' || status == '팀별 회의') ? status : '$status 예정',
              style: appFonts.t4.copyWith(
                  color: (status == '휴회' || status == '팀별 회의')
                      ? appColors.grey4
                      : appColors.grey5),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

class LateAbsenceListItem extends StatelessWidget {
  const LateAbsenceListItem({
    super.key,
    required this.week,
    required this.date,
    required this.isSelected,
    this.lateOrAbsence,
  });

  final int week;
  final String date;
  final bool isSelected;
  final String? lateOrAbsence;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: lateOrAbsence == null ? appColors.white : appColors.grey3,
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
                date,
                style: appFonts.h3.copyWith(
                    color: lateOrAbsence == null
                        ? appColors.grey6
                        : appColors.grey8),
              ),
            ],
          ),
          lateOrAbsence == null
              ? Image.asset(
                  'assets/images/icon_check.png',
                  color: isSelected ? appColors.slBlue : appColors.grey3,
                  width: 34,
                  height: 34,
                )
              : Text(
                  '$lateOrAbsence 예정',
                  style: appFonts.t4.copyWith(color: appColors.grey6),
                ),
        ],
      ),
    );
  }
}

class MyAttendanceListItem extends StatefulWidget {
  const MyAttendanceListItem({
    super.key,
    required this.name,
    required this.attendanceStatus,
  });

  final String name;
  final Map<String, dynamic> attendanceStatus;

  @override
  State<MyAttendanceListItem> createState() => _MyAttendanceListItemState();
}

class _MyAttendanceListItemState extends State<MyAttendanceListItem> {
  int? index;
  bool isTagSelected = false;
  bool didUserModify = false;

  @override
  Widget build(BuildContext context) {
    if (!didUserModify) {
      if (widget.attendanceStatus['present'].contains(widget.name)) {
        // 출석
        index = 1;
      } else if (widget.attendanceStatus['late'].contains(widget.name)) {
        // 사유 지각
        index = 2;
        isTagSelected = true;
      } else if (widget.attendanceStatus['absent'].contains(widget.name)) {
        // 사유 결석
        index = 3;
        isTagSelected = true;
      } else if (widget.attendanceStatus['badLate'].contains(widget.name)) {
        // 무단 지각
        index = 2;
      } else if (widget.attendanceStatus['badAbsent'].contains(widget.name)) {
        // 무단 결석
        index = 3;
      } else {
        index = null;
        isTagSelected = false;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Expanded(flex: 2, child: SizedBox()),
          Text(
            widget.name,
            style: appFonts.t3.copyWith(color: appColors.grey8),
          ),
          const Expanded(flex: 2, child: SizedBox(width: 10)),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.presence,
            onSelected: (bool isSelected) {
              setState(() {
                index = isSelected ? 1 : null;
                isTagSelected = false;
                didUserModify = true;
              });
            },
          ),
          const Expanded(flex: 1, child: SizedBox(width: 10)),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.late,
            onSelected: (bool isSelected) {
              setState(() {
                index = isSelected ? 2 : null;
                isTagSelected = false;
                didUserModify = true;
              });
            },
          ),
          const Expanded(flex: 1, child: SizedBox(width: 10)),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.absence,
            onSelected: (bool isSelected) {
              setState(() {
                index = isSelected ? 3 : null;
                isTagSelected = false;
                didUserModify = true;
              });
            },
          ),
        ],
      ),
    );
  }
}

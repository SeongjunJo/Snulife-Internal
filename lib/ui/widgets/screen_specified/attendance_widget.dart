import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/logics/providers/check_attendance_state.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

class CheckAttendanceListItem extends StatefulWidget {
  const CheckAttendanceListItem({
    super.key,
    required this.canModify,
    required this.name,
    required this.attendanceStatus,
  });

  final bool canModify;
  final String name;
  final Map<String, dynamic> attendanceStatus;

  @override
  State<CheckAttendanceListItem> createState() =>
      _CheckAttendanceListItemState();
}

class _CheckAttendanceListItemState extends State<CheckAttendanceListItem> {
  int? index;
  bool isTagSelected = false;
  String? initialStatus;
  bool didUserModify = false;

  @override
  Widget build(BuildContext context) {
    if (!didUserModify) {
      if (widget.attendanceStatus['present'].contains(widget.name)) {
        index = 1; // 출석
        initialStatus = '출석';
      } else if (widget.attendanceStatus['late'].contains(widget.name)) {
        index = 2; // 사유 지각
        initialStatus = '지각';
        isTagSelected = true;
      } else if (widget.attendanceStatus['absent'].contains(widget.name)) {
        index = 3; // 사유 결석
        initialStatus = '결석';
        isTagSelected = true;
      } else if (widget.attendanceStatus['badLate'].contains(widget.name)) {
        index = 2; // 무단 지각
        initialStatus = '지각';
      } else if (widget.attendanceStatus['badAbsent'].contains(widget.name)) {
        index = 3; // 무단 결석
        initialStatus = '결석';
      } else {
        index = null;
        isTagSelected = false;
      }
      context.read<CheckAttendanceState>().updateUserAttendanceStatus(
          widget.name, initialStatus, isTagSelected, false);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          AppStatusTag(
            title: const Text('사유'),
            isTurnedOn: isTagSelected,
            onPressed: (widget.canModify && (index == 2 || index == 3))
                ? () {
                    setState(() {
                      didUserModify = true;
                      isTagSelected = !isTagSelected;
                      context
                          .read<CheckAttendanceState>()
                          .updateUserAttendanceStatus(
                              widget.name, null, isTagSelected, true);
                    });
                  }
                : () {},
          ),
          const SizedBox(width: 14.5),
          Text(
            widget.name,
            style: appFonts.t3.copyWith(color: appColors.grey8),
          ),
          const Expanded(flex: 1, child: SizedBox()),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.presence,
            onSelected: widget.canModify
                ? (bool isSelected) {
                    setState(() {
                      didUserModify = true;
                      context
                          .read<CheckAttendanceState>()
                          .updateUserAttendanceStatus(
                              widget.name, isSelected ? '출석' : '', true, true);
                      index = isSelected ? 1 : null;
                      isTagSelected = false;
                    });
                  }
                : (_) {},
          ),
          const SizedBox(width: 12),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.late,
            onSelected: widget.canModify
                ? (bool isSelected) {
                    setState(() {
                      didUserModify = true;
                      context
                          .read<CheckAttendanceState>()
                          .updateUserAttendanceStatus(
                              widget.name, isSelected ? '지각' : '', false, true);
                      index = isSelected ? 2 : null;
                      isTagSelected = false;
                    });
                  }
                : (_) {},
          ),
          const SizedBox(width: 12),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.absence,
            onSelected: widget.canModify
                ? (bool isSelected) {
                    setState(() {
                      didUserModify = true;
                      context
                          .read<CheckAttendanceState>()
                          .updateUserAttendanceStatus(
                              widget.name, isSelected ? '결석' : '', false, true);
                      index = isSelected ? 3 : null;
                      isTagSelected = false;
                    });
                  }
                : (_) {},
          ),
        ],
      ),
    );
  }
}

class ClerkListItem extends StatefulWidget {
  const ClerkListItem({
    super.key,
    required this.name,
    required this.index,
    required this.selectedIndex,
    required this.onSelected,
    required this.clerkCount,
  });

  final String name;
  final int index;
  final int selectedIndex;
  final Function() onSelected;
  final int clerkCount;

  @override
  State<ClerkListItem> createState() => _ClerkListItemState();
}

class _ClerkListItemState extends State<ClerkListItem> {
  @override
  Widget build(BuildContext context) {
    bool isSelected = widget.index == widget.selectedIndex;

    return GestureDetector(
      onTap: widget.onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? appColors.subBlue2 : appColors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.name,
              style: appFonts.h3.copyWith(
                  color: isSelected ? appColors.slBlue : appColors.grey8),
            ),
            AttendanceChip(
              index: null, // clerk chip은 index 필요 없음
              type: AttendanceChipType.clerk,
              // clerk chip 단독 터치 불가, 색상 보정을 위해 isSelected 일 때 onSelected 필요
              onSelected: isSelected ? (_) {} : null,
              isSelected: isSelected, // clerk chip 전용 변수
              clerkCount: widget.clerkCount,
            ),
          ],
        ),
      ),
    );
  }
}

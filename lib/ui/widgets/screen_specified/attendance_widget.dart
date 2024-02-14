import 'package:flutter/material.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

class AttendanceListItem extends StatefulWidget {
  const AttendanceListItem({super.key});

  @override
  State<AttendanceListItem> createState() => _AttendanceListItemState();
}

class _AttendanceListItemState extends State<AttendanceListItem> {
  int? index;
  bool isTagSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          AttendanceTag(
            isSelected: isTagSelected,
            onPressed: () {
              setState(() => isTagSelected = !isTagSelected);
            },
          ),
          const Expanded(flex: 2, child: SizedBox()),
          Text("김이름", style: appFonts.t3.copyWith(color: appColors.grey8)),
          const Expanded(flex: 2, child: SizedBox(width: 10)),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.presence,
            onSelected: (bool isSelected) {
              setState(() => index = isSelected ? 1 : null);
            },
          ),
          const Expanded(flex: 1, child: SizedBox(width: 10)),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.late,
            onSelected: (bool isSelected) {
              setState(() => index = isSelected ? 2 : null);
            },
          ),
          const Expanded(flex: 1, child: SizedBox(width: 10)),
          AttendanceChip(
            index: index,
            type: AttendanceChipType.absence,
            onSelected: (bool isSelected) {
              setState(() => index = isSelected ? 3 : null);
            },
          ),
        ],
      ),
    );
  }
}

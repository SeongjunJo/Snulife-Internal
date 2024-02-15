import 'package:flutter/material.dart';
import 'package:snulife_internal/logics/common_instances.dart';
import 'package:snulife_internal/ui/widgets/commons/button_widgets.dart';

class AttendanceListItem extends StatefulWidget {
  const AttendanceListItem({super.key, required this.name});

  final String name;

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
            onPressed: (index == 2 || index == 3)
                ? () => setState(() => isTagSelected = !isTagSelected)
                : () {},
          ),
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
                isTagSelected = isSelected ? true : false;
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
                isTagSelected = isSelected ? true : false;
              });
            },
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
              clerkCount:
                  isSelected ? widget.clerkCount + 1 : widget.clerkCount,
            ),
          ],
        ),
      ),
    );
  }
}

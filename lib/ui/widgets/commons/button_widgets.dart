import 'package:flutter/material.dart';

import '../../../logics/common_instances.dart';

class AppExpandedButton extends StatelessWidget {
  const AppExpandedButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
    this.isCancelButton = false,
  });

  final String buttonText;
  final void Function()? onPressed;
  final bool isCancelButton;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          disabledBackgroundColor: appColors.grey2,
          backgroundColor: !isCancelButton ? appColors.slBlue : appColors.grey2,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: appFonts.btn.copyWith(color: appColors.white),
        ),
      ),
    );
  }
}

class AttendanceChip extends StatefulWidget {
  const AttendanceChip({
    super.key,
    required this.index,
    required this.type,
    required this.onSelected,
    this.isSelected,
    this.clerkCount = 100, // default value
  });

  final int? index;
  final AttendanceChipType type;
  final Function(bool)? onSelected;
  final bool? isSelected; // clerk chip 전용 변수
  final int clerkCount;

  @override
  State<AttendanceChip> createState() => _AttendanceChipState();
}

class _AttendanceChipState extends State<AttendanceChip> {
  late int? _index;
  late bool isSelected;
  late String text;
  late Color textColor;
  late Color selectedColor;

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case AttendanceChipType.presence:
        _index = 1;
        text = "출석";
        textColor = appColors.success;
        selectedColor = const Color(0xFFE5F4E8);
      case AttendanceChipType.late:
        _index = 2;
        text = "지각";
        textColor = appColors.bestLight;
        selectedColor = const Color(0xFFFDF8E8);
      case AttendanceChipType.absence:
        _index = 3;
        text = "결석";
        textColor = appColors.failure;
        selectedColor = const Color(0xFFFBEEEE);
      case AttendanceChipType.clerk:
        _index = null; // clerk chip은 index 필요 없이 전달 받은 isSelected 사용
        text = widget.clerkCount == 100 ? "임시" : "${widget.clerkCount} 번";
        textColor = appColors.white;
        selectedColor = appColors.slBlue;
    }
    // 전달 받은 isSelected가 null이면 다른 chip => index로 판단
    isSelected = widget.isSelected ?? _index == widget.index;

    return ChoiceChip(
      label: Text(text),
      labelStyle: appFonts.t4.copyWith(
        color: isSelected
            ? textColor
            : widget.onSelected != null
                ? appColors.grey5
                : appColors.grey8, // clerk chip 텍스트 색상 보정
      ),
      labelPadding: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      selected: isSelected,
      onSelected: widget.onSelected,
      selectedColor: selectedColor,
      backgroundColor: appColors.grey1,
      disabledColor: appColors.grey1,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 0,
          color: isSelected & (widget.type == AttendanceChipType.clerk)
              ? appColors.subBlue2 // clerk chip 활성화 배경 색상
              : appColors.white,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

enum AttendanceChipType {
  presence,
  absence,
  late,
  clerk,
}

import 'package:flutter/material.dart';

import '../../../logics/common_instances.dart';

class InfoTag extends StatefulWidget {
  const InfoTag({
    super.key,
    required this.info,
    this.isTurnedOn = false,
  });

  final String info;
  final bool isTurnedOn;

  @override
  State<InfoTag> createState() => _InfoTagState();
}

class _InfoTagState extends State<InfoTag> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: widget.isTurnedOn ? appColors.subBlue2 : appColors.grey1,
      ),
      child: Text(
        widget.info,
        style: appFonts.c2.copyWith(
          color: widget.isTurnedOn ? appColors.slBlue : appColors.grey5,
        ),
      ),
    );
  }
}

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

class AppStatusTag extends StatelessWidget {
  const AppStatusTag({
    super.key,
    required this.title,
    required this.isTurnedOn,
    required this.onPressed,
  });

  final Widget title;
  final bool isTurnedOn;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: title,
      labelStyle: appFonts.c3
          .copyWith(color: isTurnedOn ? appColors.slBlue : appColors.grey5),
      onPressed: onPressed, // null로 하면 색상이 너무 흐려짐
      backgroundColor: isTurnedOn ? appColors.subBlue2 : appColors.grey1,
      labelPadding: const EdgeInsets.symmetric(vertical: -6.5),
      padding: const EdgeInsets.symmetric(horizontal: 6.3),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 0, color: appColors.white),
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }
}

class AppTabTag extends StatelessWidget {
  const AppTabTag({
    super.key,
    required this.title,
    required this.isTurnedOn,
    required this.onPressed,
  });

  final String title;
  final bool isTurnedOn;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(title),
      labelStyle: appFonts.t4
          .copyWith(color: isTurnedOn ? appColors.slBlue : appColors.grey6),
      onPressed: onPressed,
      backgroundColor: isTurnedOn ? appColors.subBlue2 : appColors.grey0,
      labelPadding: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: isTurnedOn ? 0 : 1,
          color: isTurnedOn ? Colors.transparent : appColors.grey3,
        ),
        borderRadius: BorderRadius.circular(20),
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
    this.isSelected = false,
    this.clerkCount = 100, // default value
  });

  final int? index;
  final AttendanceChipType type;
  final bool isSelected;
  final Function(bool)? onSelected;
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
    }
    // 내 출결 현황의 chip은 항상 선택된 상태 (불이 들어온 상태)
    isSelected = widget.isSelected ? true : _index == widget.index;

    return ChoiceChip(
      label: SizedBox(width: 50, height: 34, child: Center(child: Text(text))),
      labelStyle:
          appFonts.t5.copyWith(color: isSelected ? textColor : appColors.grey5),
      labelPadding: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(0),
      selected: isSelected,
      onSelected: widget.onSelected,
      selectedColor: selectedColor,
      backgroundColor: appColors.grey1,
      disabledColor: appColors.grey1,
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 0, color: appColors.white),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

enum AttendanceChipType { presence, absence, late }

class AppDropDownMenu extends StatelessWidget {
  const AppDropDownMenu({
    super.key,
    required this.dropdowns,
    required this.onSelected,
  });

  final List<String> dropdowns;
  final Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      menuStyle: MenuStyle(
        backgroundColor: MaterialStateProperty.all(appColors.white),
        surfaceTintColor: MaterialStateProperty.all(appColors.white),
        elevation: MaterialStateProperty.all(2),
        padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
        shape: MaterialStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.only(left: 15),
        constraints: const BoxConstraints(maxHeight: 40),
      ),
      initialSelection: dropdowns.last,
      trailingIcon: Image.asset(
        'assets/images/icon_arrow_down.png',
        width: 16,
        height: 16,
        color: appColors.grey6,
      ),
      selectedTrailingIcon: Image.asset(
        'assets/images/icon_arrow_up.png',
        width: 16,
        height: 16,
        color: appColors.grey6,
      ),
      textStyle: appFonts.t4.copyWith(color: appColors.grey6),
      onSelected: (String? selectedSemester) {
        onSelected(selectedSemester!);
      },
      dropdownMenuEntries: dropdowns
          .map(
            (String semester) => DropdownMenuEntry(
              value: semester,
              label: semester,
              style: ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.comfortable,
                textStyle: MaterialStateProperty.all(appFonts.t4),
                foregroundColor: MaterialStateProperty.all(appColors.grey6),
                backgroundColor: MaterialStateProperty.all(appColors.white),
                padding:
                    MaterialStateProperty.all(const EdgeInsets.only(left: 15)),
                minimumSize:
                    MaterialStateProperty.all(const Size(double.infinity, 40)),
                maximumSize:
                    MaterialStateProperty.all(const Size(double.infinity, 40)),
              ),
            ),
          )
          .toList(),
    );
  }
}

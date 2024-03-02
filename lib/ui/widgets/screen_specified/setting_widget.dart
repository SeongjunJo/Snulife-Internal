import 'package:flutter/material.dart';

import '../../../logics/common_instances.dart';

class SettingRow extends StatelessWidget {
  final String title;
  final Widget trailing;
  final void Function()? onTap;

  const SettingRow({
    super.key,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: appFonts.t3),
            trailing,
          ],
        ),
      ),
    );
  }
}

class RightArrow extends StatelessWidget {
  const RightArrow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/icon_arrow_right.png',
        width: 22, height: 22);
  }
}

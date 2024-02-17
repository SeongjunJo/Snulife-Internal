import 'package:flutter/material.dart';

import '../../../logics/common_instances.dart';

class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
    required this.info,
  });

  final String info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: appColors.grey2,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(info, style: appFonts.b2.copyWith(color: appColors.grey6)),
    );
  }
}

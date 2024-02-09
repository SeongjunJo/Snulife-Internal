import 'package:flutter/material.dart';

import '../../../logics/global_values.dart';
import '../commons/icon_widgets.dart';
import '../commons/text_widgets.dart';

class PrimaryTab extends StatelessWidget {
  final String primaryTabName;
  final Widget primaryTabContent;
  final Widget primaryTabIcon;

  const PrimaryTab({
    super.key,
    required this.primaryTabName,
    required this.primaryTabContent,
    required this.primaryTabIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.only(left: 19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(primaryTabName, style: appFonts.homePrimaryTabName),
              const SizedBox(height: 34),
              primaryTabContent,
            ],
          ),
          primaryTabIcon,
        ],
      ),
    );
  }
}

class SecondaryTab extends StatelessWidget {
  final String name;

  const SecondaryTab({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.only(top: 15, left: 27, right: 27, bottom: 10),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const SecondaryTabIcon(),
          const SizedBox(height: 12),
          SecondaryTabName(name: name),
        ],
      ),
    );
  }
}

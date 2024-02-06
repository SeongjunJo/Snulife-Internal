import 'package:flutter/material.dart';

import '../../main.dart';

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
              Text(primaryTabName, style: appFonts.primaryTabName),
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

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/router.dart';

import '../../../logics/common_instances.dart';

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
    return GestureDetector(
      // TODO PrimaryTab이 많아지면 enum으로 관리
      onTap: primaryTabName == "출석"
          ? () => context.pushNamed(AppRoutePath.attendance)
          : null,
      child: Container(
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
                Text(
                  primaryTabName,
                  style: appFonts.h1.copyWith(color: appColors.grey8),
                ),
                const SizedBox(height: 34),
                primaryTabContent,
              ],
            ),
            primaryTabIcon,
          ],
        ),
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
          Padding(
            padding:
                const EdgeInsets.only(top: 3, left: 7, right: 3, bottom: 3),
            child: Image.asset("assets/images/icon_folder.png",
                width: 100, height: 106),
          ),
          const SizedBox(height: 12),
          Text(name, style: appFonts.t4.copyWith(color: appColors.grey5)),
        ],
      ),
    );
  }
}

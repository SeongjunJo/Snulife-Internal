import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/router.dart';
import 'package:snulife_internal/ui/widgets/commons/snackbar_widget.dart';

import '../../../logics/common_instances.dart';

class PrimaryTab extends StatelessWidget {
  const PrimaryTab({
    super.key,
    required this.primaryTabName,
    required this.primaryTabContent,
    required this.primaryTabIcon,
  });

  final PrimaryTabName primaryTabName;
  final Widget primaryTabContent;
  final Widget primaryTabIcon;

  void Function()? _onTap(
    PrimaryTabName primaryTabName,
    GoRouter goRouter,
    BuildContext context,
  ) {
    switch (primaryTabName) {
      case PrimaryTabName.attendance:
        return () => goRouter.pushNamed(AppRoutePath.attendance);
      case PrimaryTabName.management:
        return () => goRouter.pushNamed(AppRoutePath.management);
      case PrimaryTabName.receipt:
        return () => AppSnackBar.showFlushBar(
              context: context,
              message: 'TBD (언젠가 넣을 예정)',
              height: 30,
              isSuccess: true,
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    GoRouter goRouter = GoRouter.of(context);

    return GestureDetector(
      onTap: _onTap(primaryTabName, goRouter, context),
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
                  primaryTabName.name,
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
  const SecondaryTab({
    super.key,
    required this.secondaryTabName,
  });

  final SecondaryTabName secondaryTabName;

  void Function()? _onTap(
    SecondaryTabName secondaryTabName,
    // GoRouter goRouter,
    BuildContext context,
  ) {
    switch (secondaryTabName) {
      case _:
        return () => AppSnackBar.showFlushBar(
              context: context,
              message: 'TBD (언젠가 넣을 예정)',
              height: 30,
              isSuccess: true,
            );
      // TODO 기능 구현 예정
      // case SecondaryTabName.rentalLedger:
      //   return () => goRouter.pushNamed(AppRoutePath.rentalLedger);
      // case SecondaryTabName.rentalRoom:
      //   return () => goRouter.pushNamed(AppRoutePath.rentalRoom);
      // case SecondaryTabName.cleaning:
      //   return () => goRouter.pushNamed(AppRoutePath.cleaning);
      // case SecondaryTabName.anonymous:
      //   return () => goRouter.pushNamed(AppRoutePath.anonymous);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap(secondaryTabName, context),
      child: Container(
        width: 180,
        height: 180,
        padding:
            const EdgeInsets.only(top: 15, left: 27, right: 27, bottom: 10),
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
            Text(secondaryTabName.name,
                style: appFonts.t4.copyWith(color: appColors.grey5)),
          ],
        ),
      ),
    );
  }
}

enum PrimaryTabName {
  attendance('출석'),
  management('운영'),
  receipt('지출 내역');

  const PrimaryTabName(this.name);
  final String name;
}

enum SecondaryTabName {
  rentalLedger('사무실 물품 장부'),
  rentalRoom('사무실 이용 기록'),
  anonymous('대나무숲'),
  cleaning('최근 청소 기록');

  const SecondaryTabName(this.name);
  final String name;
}

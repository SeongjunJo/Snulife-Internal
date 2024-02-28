import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../logics/common_instances.dart';
import '../../../router.dart';
import '../../widgets/commons/text_widgets.dart';
import '../../widgets/screen_specified/home_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isManager,
    required this.userInfo,
    required this.clerk,
  });

  final bool isManager;
  final DocumentSnapshot userInfo;
  final String clerk;

  @override
  Widget build(BuildContext context) {
    if (firebaseInstance.userName == null ||
        firebaseInstance.userName!.isEmpty) {
      firebaseInstance.user!.updateDisplayName(userInfo['name']);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // 홈 화면은 스택에 남아 있어서 빌드 1번만 하니 future 캐싱 안 해도 됨
        Column(
          children: [
            const SizedBox(height: 48),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      userInfo['name'],
                      style: appFonts.h1.copyWith(
                        fontSize: 24,
                        color: appColors.slBlue,
                      ),
                    ),
                    Text(" 님,", style: appFonts.h1.copyWith(fontSize: 24)),
                  ],
                ),
                Text("환영해요!", style: appFonts.h1.copyWith(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                InfoBox(info: userInfo['team']),
                const SizedBox(width: 8),
                InfoBox(info: userInfo['isSenior'] ? '시니어' : '주니어'),
                const SizedBox(width: 8),
                InfoBox(info: userInfo['position']),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 34),
          child: GestureDetector(
            onTap: () {
              context.pushNamed(AppRoutePath.myAttendance);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: appColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '내 출결 관리',
                    style: appFonts.t3.copyWith(color: appColors.grey7),
                  ),
                  Image.asset(
                    'assets/images/icon_right_arrow.png',
                    width: 22,
                    height: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              PrimaryTab(
                primaryTabName: PrimaryTabName.attendance,
                primaryTabContent: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("이번 주 서기는",
                        style: appFonts.t4.copyWith(color: appColors.grey8)),
                    Row(
                      children: [
                        Text(
                          clerk,
                          style: appFonts.t4.copyWith(
                            fontWeight: FontWeight.w700,
                            color: appColors.slBlue,
                          ),
                        ),
                        Text(" 님이에요",
                            style:
                                appFonts.t4.copyWith(color: appColors.grey8)),
                      ],
                    ),
                  ],
                ),
                primaryTabIcon: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset("assets/images/icon_qs.png",
                      width: 124, height: 130),
                ),
              ),
              if (isManager)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    PrimaryTab(
                      primaryTabName: PrimaryTabName.management,
                      primaryTabContent: Text(
                        "QS 확인 및 회의 \n관리가 가능해요",
                        style: appFonts.t4.copyWith(color: appColors.grey8),
                      ),
                      primaryTabIcon: Padding(
                        padding: const EdgeInsets.only(
                            top: 9, left: 9, right: 14, bottom: 7),
                        child: Image.asset("assets/images/icon_snulife.png",
                            width: 131, height: 138),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              PrimaryTab(
                primaryTabName: PrimaryTabName.receipt,
                primaryTabContent: Text(
                  "지출 내역을\n기록 해주세요",
                  style: appFonts.t4.copyWith(color: appColors.grey8),
                ),
                primaryTabIcon: Padding(
                  padding: const EdgeInsets.only(
                      top: 9, left: 9, right: 14, bottom: 7),
                  child: Image.asset("assets/images/icon_receipt.png",
                      width: 131, height: 138),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SecondaryTab(name: "사무실 물품 장부"),
            SecondaryTab(name: "최근 청소 기록"),
          ],
        ),
        const SizedBox(height: 14),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SecondaryTab(name: "Coming Soon"),
            SecondaryTab(name: "Coming Soon"),
          ],
        ),
        const SizedBox(height: 58),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Text(
              "SNULife Internal",
              style: appFonts.t4.copyWith(color: appColors.grey3),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:snulife_internal/main.dart';

import '../../widgets/commons/icon_widgets.dart';
import '../../widgets/commons/text_widgets.dart';
import '../../widgets/screen_specified/home_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const Column(
          children: [
            SizedBox(height: 48),
            // TODO user 이름
            WelcomeText(name: "정선영"),
            SizedBox(height: 10),
            Row(
              children: [
                // TODO user의 정보
                InfoBox(info: "디자인팀"),
                SizedBox(width: 8),
                InfoBox(info: "주니어"),
              ],
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 34),
          child: Column(
            children: [
              PrimaryTab(
                primaryTabName: "출석",
                // TODO 당일 서기 이름
                primaryTabContent: AttendanceText(clerk: "정선영"),
                primaryTabIcon: AttendanceIcon(),
              ),
              SizedBox(height: 16),
              PrimaryTab(
                primaryTabName: "지출 내역",
                primaryTabContent: ReceiptText(),
                primaryTabIcon: ReceiptIcon(),
              ),
            ],
          ),
        ),
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
              style: appFonts.homeBottomText,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../logics/common_instances.dart';
import '../../widgets/commons/icon_widgets.dart';
import '../../widgets/commons/text_widgets.dart';
import '../../widgets/screen_specified/home_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<Map<String, dynamic>> userInfo;
  late final Future<String> clerk;

  @override
  void initState() {
    super.initState();
    userInfo = firestoreReader.getUserInfo();
    clerk = firestoreReader.getClerk();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // 홈 화면은 스택에 남아 있어서 빌드 1번만 하니 future 캐싱 안 해도 됨
        FutureBuilder(
          future: userInfo,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  const SizedBox(height: 48),
                  WelcomeText(name: snapshot.data['name']),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      InfoBox(info: snapshot.data['team']),
                      const SizedBox(width: 8),
                      InfoBox(info: snapshot.data['isSenior'] ? '시니어' : '주니어'),
                      const SizedBox(width: 8),
                      InfoBox(info: snapshot.data['position']),
                    ],
                  ),
                ],
              );
            } else {
              return const SizedBox(height: 105);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 34),
          child: GestureDetector(
            onTap: () {},
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
                primaryTabName: "출석",
                primaryTabContent: FutureBuilder(
                  future: clerk,
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      return AttendanceText(clerk: snapshot.data);
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
                primaryTabIcon: const AttendanceIcon(),
              ),
              const SizedBox(height: 16),
              const PrimaryTab(
                primaryTabName: "지출 내역",
                primaryTabContent: ReceiptText(),
                primaryTabIcon: ReceiptIcon(),
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

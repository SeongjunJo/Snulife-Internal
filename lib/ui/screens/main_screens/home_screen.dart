import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snulife_internal/ui/widgets/commons/shimmer.dart';
import 'package:snulife_internal/ui/widgets/commons/snackbar_widget.dart';

import '../../../logics/common_instances.dart';
import '../../../router.dart';
import '../../widgets/commons/button_widgets.dart';
import '../../widgets/screen_specified/home_widget.dart';

bool hasDisconnectedSnackBarPopped = false;
bool hasReconnectedSnackBarPopped = false;

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.isInternetConnected,
    required this.isReconnected,
    required this.isLoading,
    required this.isLoggedIn,
    required this.isManager,
    required this.userInfo,
    required this.clerk,
  });

  final bool isInternetConnected;
  final bool isReconnected;
  final bool isLoading;
  final bool isLoggedIn;
  final bool isManager;
  final Map userInfo;
  final String clerk;

  @override
  Widget build(BuildContext context) {
    if (!isInternetConnected && !hasDisconnectedSnackBarPopped) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        hasDisconnectedSnackBarPopped = true;
        hasReconnectedSnackBarPopped = false;
        AppSnackBar.showFlushBar(
          context: context,
          message: '네크워크 연결을 확인해주세요',
          height: 30,
          isSuccess: false,
        );
      });
    }
    if (isReconnected && !hasReconnectedSnackBarPopped) {
      hasReconnectedSnackBarPopped = true;
      hasDisconnectedSnackBarPopped = false;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => AppSnackBar.showFlushBar(
          context: context,
          message: '네트워크가 연결되었습니다',
          height: 30,
          isSuccess: true,
        ),
      );
    }

    if (isLoading) {
      return ShimmerLoadingAnimation(
        isLoading: true,
        child: homeShimmer(),
      );
    } else if (!isLoggedIn) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => context.goNamed(AppRoutePath.login));
      return const SizedBox();
    } else {
      if (firebaseInstance.userName == null ||
          firebaseInstance.userName!.isEmpty) {
        firebaseInstance.user!.updateDisplayName(userInfo['name']);
      }

      return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
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
                  InfoTag(info: userInfo['position']),
                  const SizedBox(width: 8),
                  InfoTag(info: userInfo['team']),
                  const SizedBox(width: 8),
                  InfoTag(
                      info: userInfo['isAlum']
                          ? '알럼나이'
                          : userInfo['isSenior']
                              ? '시니어'
                              : '주니어'),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
                      'assets/images/icon_arrow_right.png',
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
                    child: Image.asset("assets/images/icon_attendance.png",
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
                              top: 20, left: 0, right: 13, bottom: 20),
                          child: Image.asset(
                              "assets/images/icon_management.png",
                              width: 131,
                              height: 112),
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
              SecondaryTab(secondaryTabName: SecondaryTabName.rentalLedger),
              SecondaryTab(secondaryTabName: SecondaryTabName.rentalRoom),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SecondaryTab(secondaryTabName: SecondaryTabName.cleaning),
              SecondaryTab(secondaryTabName: SecondaryTabName.anonymous),
            ],
          ),
          const SizedBox(height: 58),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "SNULife Internal",
                  style: appFonts.t4.copyWith(color: appColors.grey4),
                ),
                const SizedBox(width: 8),
                Container(width: 1, height: 16, color: appColors.grey4),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text("오픈소스 라이선스"),
                      content: _buildOpenSourceContent(),
                      actions: [
                        CupertinoDialogAction(
                          textStyle:
                              appFonts.h3.copyWith(color: appColors.slBlue),
                          onPressed: () => Navigator.pop(context),
                          child: const Text("확인"),
                        ),
                      ],
                    ),
                  ),
                  child: Text(
                    "오픈소스 라이선스",
                    style: appFonts.t4.copyWith(color: appColors.grey4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }
  }

  ListView homeShimmer() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Container(
              width: 100,
              height: 72,
              decoration: BoxDecoration(
                color: appColors.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 170,
              height: 30,
              decoration: BoxDecoration(
                color: appColors.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 34),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: appColors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 162,
                decoration: BoxDecoration(
                  color: appColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              if (isManager)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      height: 162,
                      decoration: BoxDecoration(
                        color: appColors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 162,
                decoration: BoxDecoration(
                  color: appColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: appColors.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: appColors.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: appColors.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: appColors.grey1,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 58),
      ],
    );
  }
}

Column _buildOpenSourceContent() {
  return const Column(
    children: [
      SizedBox(height: 16),
      Text("MIT | provider | dash-overflow.net"),
      Text("MIT | flutter_launcher_icons | fluttercommunity.dev"),
      Text("MIT | flutter_native_splash | jonhanson.net"),
      Text("MIT | another_flushbar | hamidwakili.com"),
      Text("MIT | internet_connection_checker | (unverified)"),
      Text("MIT | dotted_border | (unverified)"),
      Text("BSD-3-Clause | async | flutter.dev"),
      Text("BSD-3-Clause | firebase_core | firebase.google.com"),
      Text("BSD-3-Clause | firebase_auth | firebase.google.com"),
      Text("BSD-3-Clause | cloud_firestore | firebase.google.com"),
      Text("BSD-3-Clause | go_router | flutter.dev"),
      Text("BSD-3-Clause | http | flutter.dev"),
      Text("BSD-3-Clause | html | flutter.dev"),
      Text("BSD-3-Clause | flutter_lints | flutter.dev"),
      Text("OFL-1.1 license | Spoqa Han Sans Neo | Spoqa"),
    ],
  );
}

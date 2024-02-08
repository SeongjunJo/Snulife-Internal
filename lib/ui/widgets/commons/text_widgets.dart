import 'package:flutter/material.dart';

import '../../../main.dart';

class WelcomeText extends StatelessWidget {
  final String name;

  const WelcomeText({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(name, style: appFonts.homePersonName),
            Text(" 님,", style: appFonts.homeWelcomeText),
          ],
        ),
        Text("환영해요!", style: appFonts.homeWelcomeText),
      ],
    );
  }
}

class InfoBox extends StatelessWidget {
  final String info;

  const InfoBox({
    super.key,
    required this.info,
  });

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
      child: Text(info, style: appFonts.homePersonInfo),
    );
  }
}

class AttendanceText extends StatelessWidget {
  final String clerk;

  const AttendanceText({
    super.key,
    required this.clerk,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("오늘 서기는", style: appFonts.homePrimaryTabContent),
        Row(
          children: [
            Text(clerk, style: appFonts.homePrimaryTabPersonName),
            Text(" 님이에요", style: appFonts.homePrimaryTabContent),
          ],
        ),
      ],
    );
  }
}

class ReceiptText extends StatelessWidget {
  const ReceiptText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text("지출 내역을\n기록 해주세요.", style: appFonts.homePrimaryTabContent);
  }
}

class SecondaryTabName extends StatelessWidget {
  final String name;

  const SecondaryTabName({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Text(name, style: appFonts.homeSecondaryTabName);
  }
}

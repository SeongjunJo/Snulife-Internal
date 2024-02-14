import 'package:flutter/material.dart';

import '../../../logics/common_instances.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              name,
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
    );
  }
}

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

class AttendanceText extends StatelessWidget {
  const AttendanceText({
    super.key,
    required this.clerk,
  });

  final String clerk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("이번 주 서기는", style: appFonts.t4.copyWith(color: appColors.grey8)),
        Row(
          children: [
            Text(
              clerk,
              style: appFonts.t4.copyWith(
                fontWeight: FontWeight.w700,
                color: appColors.slBlue,
              ),
            ),
            Text(" 님이에요", style: appFonts.t4.copyWith(color: appColors.grey8)),
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
    return Text(
      "지출 내역을\n기록 해주세요.",
      style: appFonts.t4.copyWith(color: appColors.grey8),
    );
  }
}

class SecondaryTabName extends StatelessWidget {
  const SecondaryTabName({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(name, style: appFonts.t4.copyWith(color: appColors.grey5));
  }
}

class ClerkRotationText extends StatelessWidget {
  const ClerkRotationText({
    super.key,
    required this.clerk,
    required this.nextClerk,
  });

  final String clerk;
  final String nextClerk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "오늘의 서기는 ",
              style: appFonts.b2.copyWith(color: appColors.grey7),
            ),
            Text(
              clerk,
              style: appFonts.b2.copyWith(
                color: appColors.grey7,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              " 님입니다.",
              style: appFonts.b2.copyWith(color: appColors.grey7),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "다음 서기는 ",
              style: appFonts.b2.copyWith(color: appColors.grey7),
            ),
            Text(
              nextClerk,
              style: appFonts.b2.copyWith(
                color: appColors.grey7,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              " 님이에요.",
              style: appFonts.b2.copyWith(color: appColors.grey7),
            ),
          ],
        ),
      ],
    );
  }
}

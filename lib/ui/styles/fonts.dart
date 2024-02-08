import 'package:flutter/material.dart';
import 'package:snulife_internal/main.dart';

@immutable
class AppFonts {
  late final TextStyle h1 =
      _createTextStyle(sizePx: 20, heightPx: 30, weight: FontWeight.w700);
  late final TextStyle h2 =
      _createTextStyle(sizePx: 20, heightPx: 30, weight: FontWeight.w500);
  late final TextStyle h3 =
      _createTextStyle(sizePx: 17, heightPx: 26, weight: FontWeight.w500);

  late final TextStyle tm =
      _createTextStyle(sizePx: 17, heightPx: 25, weight: FontWeight.w700);
  late final TextStyle t3 =
      _createTextStyle(sizePx: 15, heightPx: 22, weight: FontWeight.w500);
  late final TextStyle t4 =
      _createTextStyle(sizePx: 14, heightPx: 20, weight: FontWeight.w500);
  late final TextStyle t5 =
      _createTextStyle(sizePx: 13, heightPx: 19, weight: FontWeight.w500);

  late final TextStyle pm =
      _createTextStyle(sizePx: 13, heightPx: 24, weight: FontWeight.w400);
  late final TextStyle b1 =
      _createTextStyle(sizePx: 15, heightPx: 22, weight: FontWeight.w500);
  late final TextStyle b2 =
      _createTextStyle(sizePx: 14, heightPx: 20, weight: FontWeight.w400);
  late final TextStyle b5 =
      _createTextStyle(sizePx: 12, heightPx: 18, weight: FontWeight.w400);

  late final TextStyle c2 =
      _createTextStyle(sizePx: 12, heightPx: 18, weight: FontWeight.w500);
  late final TextStyle c3 =
      _createTextStyle(sizePx: 11, heightPx: 17, weight: FontWeight.w400);
  late final TextStyle c4 =
      _createTextStyle(sizePx: 9, heightPx: 15, weight: FontWeight.w400);

  late final TextStyle btn =
      _createTextStyle(sizePx: 16, heightPx: 27, weight: FontWeight.w700);

  late final TextStyle largeBtn = _createTextStyle(
    sizePx: 17,
    heightPx: 25,
    weight: FontWeight.w700,
    color: appColors.white,
  );

  late final TextStyle signScreensTitle =
      _createTextStyle(sizePx: 20, heightPx: 30, weight: FontWeight.w700);

  late final TextStyle loginTitle =
      _createTextStyle(sizePx: 20, heightPx: 30, weight: FontWeight.w700);

  late final TextStyle loginFieldTitle =
      _createTextStyle(sizePx: 16, heightPx: 25, weight: FontWeight.w500);

  late final TextStyle loginFieldHint = _createTextStyle(
    sizePx: 14,
    heightPx: 20,
    weight: FontWeight.w400,
    color: appColors.grey4,
  );

  late final TextStyle loginAutoLoginText = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w500,
    color: appColors.grey8,
  );

  late final TextStyle loginForgotPasswordAskText = _createTextStyle(
    sizePx: 14,
    heightPx: 20,
    weight: FontWeight.w400,
    color: appColors.grey5,
  );

  late final TextStyle homePersonName = _createTextStyle(
    sizePx: 24,
    heightPx: 30,
    weight: FontWeight.w700,
    color: appColors.slBlue,
  );

  late final TextStyle homeWelcomeText =
      _createTextStyle(sizePx: 24, heightPx: 30, weight: FontWeight.w700);

  late final TextStyle homePersonInfo = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w500,
    color: appColors.grey6,
  );

  late final TextStyle homePrimaryTabName = _createTextStyle(
    sizePx: 28,
    heightPx: 25,
    weight: FontWeight.w500,
    color: appColors.grey8,
  );

  late final TextStyle homePrimaryTabContent = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w500,
    color: appColors.grey8,
  );

  late final TextStyle homePrimaryTabPersonName = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w700,
    color: appColors.slBlue,
  );

  late final TextStyle homeBottomText = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w500,
    color: appColors.grey3,
  );

  late final TextStyle homeSecondaryTabName = _createTextStyle(
    sizePx: 16,
    heightPx: 25,
    weight: FontWeight.w500,
    color: appColors.grey5,
  );

  late final TextStyle appBarTitle = _createTextStyle(
    sizePx: 18,
    heightPx: 20,
    weight: FontWeight.w700,
    color: appColors.grey7,
  );

  late final TextStyle settingTabTitle =
      _createTextStyle(sizePx: 16, heightPx: 25, weight: FontWeight.w500);

  TextStyle _createTextStyle({
    required double sizePx,
    required double heightPx,
    required FontWeight weight,
    Color? color,
  }) {
    const TextStyle textStyle = TextStyle(fontFamily: 'Spoqa Han Sans Neo');

    return textStyle.copyWith(
      fontSize: sizePx,
      height: heightPx / sizePx,
      fontWeight: weight,
      color: color ?? appColors.grey9,
    );
  }
}

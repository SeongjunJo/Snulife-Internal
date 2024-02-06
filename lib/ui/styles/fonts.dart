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

  late final TextStyle name = _createTextStyle(
    sizePx: 24,
    heightPx: 30,
    weight: FontWeight.w700,
    color: appColors.slBlue,
  );

  late final TextStyle welcome =
      _createTextStyle(sizePx: 24, heightPx: 30, weight: FontWeight.w700);

  late final TextStyle info = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w500,
    color: appColors.grey6,
  );

  late final TextStyle primaryTabName = _createTextStyle(
    sizePx: 28,
    heightPx: 25,
    weight: FontWeight.w500,
    color: appColors.grey8,
  );

  late final TextStyle primaryTabContent = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w500,
    color: appColors.grey8,
  );

  late final TextStyle primaryTabPerson = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w700,
    color: appColors.slBlue,
  );

  late final TextStyle bottomLogo = _createTextStyle(
    sizePx: 14,
    heightPx: 18,
    weight: FontWeight.w500,
    color: appColors.grey3,
  );

  late final TextStyle secondaryTabName = _createTextStyle(
    sizePx: 14,
    heightPx: 25,
    weight: FontWeight.w500,
    color: appColors.grey5,
  );

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

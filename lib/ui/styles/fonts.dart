import 'package:flutter/material.dart';

@immutable
class Font {
  late final TextStyle h1 =
      _createFont(sizePx: 20, heightPx: 30, weight: FontWeight.w700);
  late final TextStyle h2 =
      _createFont(sizePx: 20, heightPx: 30, weight: FontWeight.w500);
  late final TextStyle h3 =
      _createFont(sizePx: 17, heightPx: 26, weight: FontWeight.w500);

  late final TextStyle tm =
      _createFont(sizePx: 17, heightPx: 25, weight: FontWeight.w700);
  late final TextStyle t3 =
      _createFont(sizePx: 15, heightPx: 22, weight: FontWeight.w500);
  late final TextStyle t4 =
      _createFont(sizePx: 14, heightPx: 20, weight: FontWeight.w500);
  late final TextStyle t5 =
      _createFont(sizePx: 13, heightPx: 19, weight: FontWeight.w500);

  late final TextStyle pm =
      _createFont(sizePx: 13, heightPx: 24, weight: FontWeight.w400);
  late final TextStyle b1 =
      _createFont(sizePx: 15, heightPx: 22, weight: FontWeight.w500);
  late final TextStyle b2 =
      _createFont(sizePx: 14, heightPx: 20, weight: FontWeight.w400);
  late final TextStyle b5 =
      _createFont(sizePx: 12, heightPx: 18, weight: FontWeight.w400);

  late final TextStyle c2 =
      _createFont(sizePx: 12, heightPx: 18, weight: FontWeight.w500);
  late final TextStyle c3 =
      _createFont(sizePx: 11, heightPx: 17, weight: FontWeight.w400);
  late final TextStyle c4 =
      _createFont(sizePx: 9, heightPx: 15, weight: FontWeight.w400);

  late final TextStyle btn =
      _createFont(sizePx: 16, heightPx: 27, weight: FontWeight.w700);

  TextStyle _createFont({
    required double sizePx,
    required double? heightPx,
    required FontWeight? weight,
  }) {
    const TextStyle textStyle = TextStyle(fontFamily: 'Spoqa Han Sans Neo');

    return textStyle.copyWith(
      fontSize: sizePx,
      height: heightPx,
      fontWeight: weight,
    );
  }
}

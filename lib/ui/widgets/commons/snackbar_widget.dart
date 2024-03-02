import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../../logics/common_instances.dart';

class AppSnackBar {
  static showFlushbar(BuildContext context, String message, bool isSuccess) {
    final image = isSuccess
        ? Image.asset("assets/images/icon_check.png",
            width: 34, height: 34, color: appColors.slBlue)
        : Image.asset("assets/images/icon_delete.png", width: 34, height: 34);

    Flushbar(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin:
          EdgeInsets.symmetric(vertical: isSuccess ? 100 : 340, horizontal: 20),
      backgroundColor: isSuccess ? appColors.subBlue2 : const Color(0xFFFDD3D3),
      borderRadius: BorderRadius.circular(12),
      duration: const Duration(seconds: 2),
      isDismissible: false,
      positionOffset: 10,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      reverseAnimationCurve: Curves.fastEaseInToSlowEaseOut,
      messageText: Row(
        children: [
          image,
          const SizedBox(width: 12),
          Text(
            message,
            style: appFonts.t5.copyWith(
              color: isSuccess ? appColors.slBlue : appColors.failure,
            ),
          ),
        ],
      ),
    ).show(context);
  }
}

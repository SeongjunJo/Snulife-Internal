import 'package:flutter/material.dart';

import '../../../main.dart';

class AppLargeButton extends StatelessWidget {
  const AppLargeButton({
    super.key,
    required this.buttonText,
    required this.onPressed,
  });

  final String buttonText;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: appColors.slBlue,
          minimumSize: const Size(320, 50),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(buttonText, style: appFonts.largeBtn),
      ),
    );
  }
}

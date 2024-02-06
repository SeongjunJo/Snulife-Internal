import 'package:flutter/material.dart';

class AttendanceIcon extends StatelessWidget {
  const AttendanceIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Image.asset("assets/images/icon_qs.png", width: 124, height: 130),
    );
  }
}

class ReceiptIcon extends StatelessWidget {
  const ReceiptIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 9, left: 9, right: 14, bottom: 7),
      child: Image.asset("assets/images/icon_receipt.png",
          width: 131, height: 138),
    );
  }
}

class SecondaryTabIcon extends StatelessWidget {
  const SecondaryTabIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 7, right: 3, bottom: 3),
      child:
          Image.asset("assets/images/icon_folder.png", width: 90, height: 94),
    );
  }
}

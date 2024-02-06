import 'package:flutter/cupertino.dart';

import '../../main.dart';

class SettingRow extends StatelessWidget {
  final String title;
  final Widget trailing;

  const SettingRow({
    super.key,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: appFonts.settingText),
          trailing,
        ],
      ),
    );
  }
}

class RightArrow extends StatelessWidget {
  const RightArrow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset('assets/images/icon_right_arrow.png',
        width: 22, height: 22);
  }
}

class NotificationSwitch extends StatefulWidget {
  const NotificationSwitch({super.key});

  @override
  State<NotificationSwitch> createState() => _NotificationSwitchState();
}

class _NotificationSwitchState extends State<NotificationSwitch> {
  bool switchValue = true;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.8,
      child: CupertinoSwitch(
        // This bool value toggles the switch.
        value: switchValue,
        activeColor: appColors.slBlue,
        onChanged: (bool? value) {
          setState(
            () {
              switchValue = value ?? false;
            },
          );
        },
      ),
    );
  }
}

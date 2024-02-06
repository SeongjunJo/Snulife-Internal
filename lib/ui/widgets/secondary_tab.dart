import 'package:flutter/material.dart';
import 'package:snulife_internal/ui/widgets/text_widget.dart';

import '../../main.dart';
import 'icon_widget.dart';

class SecondaryTab extends StatelessWidget {
  final String name;

  const SecondaryTab({
    super.key,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      height: 180,
      padding: const EdgeInsets.only(top: 15, left: 27, right: 27, bottom: 10),
      decoration: BoxDecoration(
        color: appColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const SecondaryTabIcon(),
          const SizedBox(height: 12),
          SecondaryTabName(name: name),
        ],
      ),
    );
  }
}

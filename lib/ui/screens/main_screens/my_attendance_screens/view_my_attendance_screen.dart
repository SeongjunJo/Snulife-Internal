import 'package:flutter/material.dart';

class ViewMyAttendancePage extends StatelessWidget {
  const ViewMyAttendancePage(
      {super.key, required this.text, required this.onPressed});

  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(text),
          ElevatedButton(
            onPressed: onPressed,
            child: const Text('지각/결석'),
          ),
        ],
      ),
    );
  }
}

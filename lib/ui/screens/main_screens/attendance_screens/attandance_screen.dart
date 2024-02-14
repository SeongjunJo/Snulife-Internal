import 'package:flutter/material.dart';
import 'package:snulife_internal/ui/screens/main_screens/attendance_screens/clerk_screen.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  Widget build(BuildContext context) {
    return const ClerkPage();
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snulife_internal/logics/providers/select_semester_states.dart';

class ViewMyAttendancePage extends StatelessWidget {
  const ViewMyAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SelectSemesterStatus>(
      builder: (BuildContext context, value, _) {
        return Center(
          child: Column(
            children: [
              Text(value.selectedSemester),
              ElevatedButton(
                onPressed: value.changeSemester,
                child: const Text('지각/결석'),
              ),
            ],
          ),
        );
      },
    );
  }
}

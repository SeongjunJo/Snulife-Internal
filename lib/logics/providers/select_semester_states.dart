import 'package:flutter/material.dart';

class SelectSemesterStatus extends ChangeNotifier {
  SelectSemesterStatus({required this.currentSemester});

  final String currentSemester;
  late String _selectedSemester = currentSemester;
  String get selectedSemester => _selectedSemester;

  changeSemester(String semester) {
    _selectedSemester = semester;
    notifyListeners();
  }
}

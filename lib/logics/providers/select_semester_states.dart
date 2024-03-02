import 'package:flutter/material.dart';

class SelectSemesterStatus extends ChangeNotifier {
  SelectSemesterStatus({required this.currentSemester});

  final String currentSemester;
  late String _selectedSemester = currentSemester;
  String get selectedSemester => _selectedSemester;

  changeSemester(String semester) {
    final temp = _selectedSemester;
    _selectedSemester = semester;
    if (temp != _selectedSemester) notifyListeners(); // 같은 학기 선택시 새로 고침 방지
  }
}

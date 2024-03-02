import 'package:flutter/material.dart';

class SelectSemesterStatus extends ChangeNotifier {
  SelectSemesterStatus({required this.currentSemester});

  final String currentSemester;
  late String _selectedSemester = currentSemester;
  String get selectedSemester => _selectedSemester;

  // TODO 이 provider를 다른 화면에서도 쓸 때, selectedSemester가 유지되는지
  // => 만약 유지된다면, reset하는 함수 만들어서 dispose할 때 call
  changeSemester(String semester) {
    final temp = _selectedSemester;
    _selectedSemester = semester;
    if (temp != _selectedSemester) notifyListeners(); // 같은 학기 선택시 새로 고침 방지
  }
}

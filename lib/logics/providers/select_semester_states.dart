import 'package:flutter/material.dart';

class SelectSemesterStatus extends ChangeNotifier {
  SelectSemesterStatus({required this.currentSemester});

  final String currentSemester;
  late String _selectedSemester = currentSemester;
  String get selectedSemester => _selectedSemester;

  void Function()? changeSemester() {
    _selectedSemester = 'semester';
    notifyListeners();
    return null;
  }
}

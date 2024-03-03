import 'package:flutter/material.dart';

class DropdownSelectionStatus extends ChangeNotifier {
  DropdownSelectionStatus({required this.currentSelection});

  final String currentSelection;
  late String _selectedSelection = currentSelection;
  String get selectedSelection => _selectedSelection;

  changeSelection(String selection) {
    final temp = _selectedSelection;
    _selectedSelection = selection;
    if (temp != _selectedSelection) notifyListeners(); // 같은 학기 선택시 새로 고침 방지
  }
}

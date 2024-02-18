import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

class HttpLogic {
  static const snuAcademicCalendarUrl =
      'https://www.snu.ac.kr/academics/resources/calendar';

  Future<String> getAcademicCalendar() async {
    debugPrint('getAcademicCalendar');
    final response = await http.get(Uri.parse(snuAcademicCalendarUrl));
    dom.Document document = parser.parse(response.body);
    final academicCalendar =
        document.querySelector('section.ly-section.calendar');

    return academicCalendar!.innerHtml;
  }
}

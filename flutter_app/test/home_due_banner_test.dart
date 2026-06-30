import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aws_docs/pages/home_page.dart';

void main() {
  test('dueIcon: overdue>0이면 event_busy, 없으면 event_upcoming', () {
    expect(dueIcon(3), Icons.event_busy_outlined);
    expect(dueIcon(1), Icons.event_busy_outlined);
    expect(dueIcon(0), Icons.event_outlined);
  });
}

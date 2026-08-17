import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfa/main.dart';

void main() {
  testWidgets('App renders MaterialApp without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

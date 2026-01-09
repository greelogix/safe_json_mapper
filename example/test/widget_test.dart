// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:safe_json_mapper_example/main.dart';

void main() {
  testWidgets('SafeJsonMapper Demo UI loads correctly',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our title and initial text are present.
    expect(find.text('🛡️ SafeJsonMapper Demo'), findsOneWidget);
    expect(find.text("Select a scenario to witness SafeModel's power"),
        findsOneWidget);

    // Verify that scenario buttons are present
    expect(find.text('Perfect Success'), findsOneWidget);
    expect(find.text('Optimal JSON'), findsOneWidget);
    expect(find.text('Type & Case Drift'), findsOneWidget);
    expect(find.text('Nulls & Missing'), findsOneWidget);
    expect(find.text('Invalid Nested'), findsOneWidget);

    // Verify sections are present
    expect(find.text('Current Input JSON'), findsOneWidget);
    expect(find.text('Parsing Result'), findsOneWidget);
    expect(find.text('Scenarios'), findsOneWidget);
  });
}

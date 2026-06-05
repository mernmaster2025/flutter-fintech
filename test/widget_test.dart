import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_fintech/src/app.dart';

void main() {
  testWidgets('renders the backend-ready crypto shell', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FintechApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('Live portfolio'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}

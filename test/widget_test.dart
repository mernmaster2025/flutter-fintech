import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_fintech/src/app.dart';

void main() {
  testWidgets('renders the premium fintech shell', (tester) async {
    await tester.pumpWidget(const FintechApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('Premium Treasury'), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
  });
}

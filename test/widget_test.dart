import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo_template_hello_g/screen/user_dynamic_form_screen.dart';

void main() {
  testWidgets('shows the default workshop template on launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: UserDynamicFormScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Workshop'), findsOneWidget);
    expect(find.text('Workshop details'), findsOneWidget);
    expect(find.text('Upload .json Template'), findsOneWidget);
  });
}

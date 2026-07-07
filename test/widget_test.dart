import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo_template_hello_g/screen/user_dynamic_form_screen.dart';

void main() {
  testWidgets(
    'shows the default driving template and template switching tabs',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: UserDynamicFormScreen()));
      await tester.pumpAndSettle();

      // Verify template selector tabs are visible
      expect(find.text('Driving'), findsOneWidget);
      expect(find.text('Dance'), findsOneWidget);
      expect(find.text('Computer'), findsOneWidget);

      // Verify default template loads (Driving)
      expect(find.text('Vehicle Driving Academy'), findsOneWidget);
      expect(find.text('Course Details'), findsOneWidget);
      expect(find.text('Upload Custom .json Template'), findsOneWidget);
    },
  );
}

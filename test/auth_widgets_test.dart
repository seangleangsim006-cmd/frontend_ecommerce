import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_flutter/core/widgets/app_button.dart';
import 'package:widget_flutter/core/widgets/app_text_field.dart';

void main() {
  testWidgets('password field toggles visibility and loading button shows spinner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AppTextField(
                hintText: 'Password',
                controller: TextEditingController(),
                isPassword: true,
              ),
              const AppButton(
                text: 'Login',
                onPressed: null,
                isLoading: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lildairy/screens/subscription/subscription_dialog.dart';

void main() {
  testWidgets('SubscriptionDialog smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    SubscriptionDialog.show(
                      context,
                      title: "Upgrade to Premium",
                      description: "Unlock all premium features today!",
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Show Dialog'), findsOneWidget);
    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Upgrade to Premium'), findsOneWidget);
    expect(find.text('Unlock all premium features today!'), findsOneWidget);
    expect(find.text('Upgrade'), findsOneWidget);
    expect(find.text('Maybe Later'), findsOneWidget);

    await tester.tap(find.text('Maybe Later'));
    await tester.pumpAndSettle();

    expect(find.text('Upgrade to Premium'), findsNothing);
  });
}

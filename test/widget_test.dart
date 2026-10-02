import 'package:flutter_test/flutter_test.dart';
import 'package:autocare_ai/main.dart';

void main() {
  testWidgets('AutoCare AI login screen test', (WidgetTester tester) async {
    await tester.pumpWidget(const AutoCareApp());

    expect(find.text('AutoCare AI'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
  });
}
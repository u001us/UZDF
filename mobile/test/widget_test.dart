import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('UZDF app runs', (WidgetTester tester) async {
    await tester.pumpWidget(const UzdfApp());
    expect(find.byType(UzdfApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:dawenly_app/main.dart';

void main() {
  testWidgets('DawenlyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DawenlyApp());
    expect(find.byType(DawenlyApp), findsOneWidget);
  });
}

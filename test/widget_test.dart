import 'package:flutter_test/flutter_test.dart';

import 'package:campus_vibes/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusVibesApp());
    expect(find.text('Campus Vibes'), findsOneWidget);
  });
}

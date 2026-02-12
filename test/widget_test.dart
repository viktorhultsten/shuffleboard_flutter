import 'package:flutter_test/flutter_test.dart';

import 'package:shuffleboard_flutter/old.main.dart';

void main() {
  testWidgets('Scoreboard renders both teams', (WidgetTester tester) async {
    await tester.pumpWidget(const ShuffleboardApp());
    await tester.pump();

    expect(find.text('BLUE'), findsOneWidget);
    expect(find.text('RED'), findsOneWidget);
    expect(find.text('0'), findsNWidgets(2));
    expect(find.text('VS'), findsOneWidget);
  });

  testWidgets('Tapping +1 increments score', (WidgetTester tester) async {
    await tester.pumpWidget(const ShuffleboardApp());
    await tester.pump();

    final plusOneButtons = find.text('+1');
    await tester.tap(plusOneButtons.first);
    await tester.pump();

    // Score "1" appears once for the left team score, plus once in the round indicator
    expect(find.text('1'), findsNWidgets(2));
  });
}

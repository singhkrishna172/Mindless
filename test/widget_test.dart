import 'package:flutter_test/flutter_test.dart';
import 'package:mindless/main.dart';
import 'package:mindless/navigation/navbar.dart';
import 'package:mindless/pages/home.dart';
import 'package:mindless/pages/minimal_launcher.dart';

void main() {
  testWidgets('MindLess home page and navigation bar smoke test', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MindlessApp());
    expect(find.byType(HomePage), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(HomePage), findsOneWidget);

    // Verify MindlessNavBar is rendered
    expect(find.byType(MindlessNavBar), findsOneWidget);

    // Verify tabs are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Home opens the minimal launcher manually', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MindlessApp());
    await tester.tap(find.text('Minimal launcher'));
    await tester.pumpAndSettle();

    expect(find.byType(MinimalLauncherPage), findsOneWidget);
    expect(find.textContaining('Opened manually'), findsOneWidget);
  });
}

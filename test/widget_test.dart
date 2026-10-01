import 'package:flutter_test/flutter_test.dart';

import 'package:brivora/features/auth/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('Brivora splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(onAuthCheck: _skipAuthCheck),
      ),
    );

    await tester.pump();

    expect(find.text('Brivora'), findsOneWidget);
    expect(find.text('PROJECT MANAGEMENT'), findsOneWidget);
  });
}

Future<void> _skipAuthCheck() async {}

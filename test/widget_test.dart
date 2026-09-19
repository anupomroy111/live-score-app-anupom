import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_score_app/main.dart';

void main() {
  testWidgets('shows setup instructions when Firebase initialization fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      const LiveScoreApp(setupError: 'Missing configuration'),
    );
    expect(find.text('Firebase setup needed'), findsOneWidget);
    expect(find.text('Missing configuration'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
  });
}

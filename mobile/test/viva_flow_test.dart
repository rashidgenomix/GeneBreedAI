import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:genebreed_ai/main.dart';
import 'package:genebreed_ai/router.dart';
import 'package:genebreed_ai/data/viva_questions.dart';

void main() {
  testWidgets('Viva: topic -> stage map -> question session -> summary -> review', (WidgetTester tester) async {
    await tester.pumpWidget(const GeneBreedApp());
    await tester.pumpAndSettle();
    rootNavigatorKey.currentContext!.go('/viva');
    await tester.pumpAndSettle();

    // Every topic should render as a card.
    for (final t in vivaTopics) {
      expect(find.text(t.name), findsOneWidget);
    }

    await tester.tap(find.text(vivaTopics.first.name));
    await tester.pumpAndSettle();

    // Foundation stage should be tappable; Intermediate/Advanced start locked.
    expect(find.text('Foundation'), findsOneWidget);
    await tester.tap(find.text('Foundation'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Answer every question in the stage (always tap the first option) until the summary shows.
    for (var i = 0; i < 10; i++) {
      final questionCount = find.textContaining('Question ');
      if (questionCount.evaluate().isEmpty) break;

      final optionTiles = find.byType(ListTile);
      expect(optionTiles, findsWidgets);
      await tester.ensureVisible(optionTiles.first);
      await tester.pumpAndSettle();
      await tester.tap(optionTiles.first);
      await tester.pumpAndSettle();

      final nextOrFinish = find.textContaining('Next Question');
      final finish = find.text('Finish Stage');
      final actionFinder = finish.evaluate().isNotEmpty ? finish : nextOrFinish;
      if (actionFinder.evaluate().isNotEmpty) {
        await tester.ensureVisible(actionFinder);
        await tester.pumpAndSettle();
        await tester.tap(actionFinder);
      }
      await tester.pumpAndSettle();
    }

    // Should now be on the summary screen with a review list.
    expect(find.text('Review answers'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Tapping a review row should open a detail sheet without error.
    final reviewChevron = find.byIcon(Icons.chevron_right).first;
    await tester.ensureVisible(reviewChevron);
    await tester.pumpAndSettle();
    await tester.tap(reviewChevron);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

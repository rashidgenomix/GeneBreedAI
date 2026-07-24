import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:genebreed_ai/main.dart';
import 'package:genebreed_ai/router.dart';

Future<void> _expectNoException(WidgetTester tester, String label) async {
  expect(tester.takeException(), isNull, reason: '$label threw an exception');
}

void main() {
  testWidgets('All Genetics Games open without error', (WidgetTester tester) async {
    await tester.pumpWidget(const GeneBreedApp());
    await tester.pumpAndSettle();
    rootNavigatorKey.currentContext!.go('/games');
    await tester.pumpAndSettle();

    const games = [
      'Trait Prediction',
      'Gene Matching',
      'DNA Puzzle',
      'Chromosome Assembly',
      'Mutation Challenge',
      'Breeding Escape Room',
      'Pedigree Puzzle',
      'Genome Mapping',
    ];

    for (final title in games) {
      final finder = find.text(title).first;
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await _expectNoException(tester, title);

      final backButton = find.text('← Back to Games');
      expect(backButton, findsOneWidget, reason: '$title should show a back button');
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      await _expectNoException(tester, '$title (returning)');
    }
  });

  testWidgets('All Virtual Research Lab analyses open without error', (WidgetTester tester) async {
    await tester.pumpWidget(const GeneBreedApp());
    await tester.pumpAndSettle();
    rootNavigatorKey.currentContext!.go('/research-lab');
    await tester.pumpAndSettle();

    const analyses = [
      'Heritability & Genetic Advance',
      'ANOVA (Randomized Block Design)',
      'Line × Tester Analysis',
      'QTL Mapping',
      'Genome-Wide Association Study',
    ];

    for (final title in analyses) {
      final finder = find.text(title).first;
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await _expectNoException(tester, title);

      final backButton = find.text('← Back to Lab');
      expect(backButton, findsOneWidget, reason: '$title should show a back button');
      await tester.tap(backButton);
      await tester.pumpAndSettle();
      await _expectNoException(tester, '$title (returning)');
    }
  });
}

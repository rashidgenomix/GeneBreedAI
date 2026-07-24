import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:genebreed_ai/main.dart';
import 'package:genebreed_ai/router.dart';

const _routes = [
  '/',
  '/breeder',
  '/gene-lab',
  '/detective',
  '/supervisor',
  '/viva',
  '/games',
  '/research-lab',
  '/notebook',
  '/career',
];

Future<void> _runAtSize(WidgetTester tester, String label, double width, double height) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const GeneBreedApp());
  await tester.pumpAndSettle();

  for (final route in _routes) {
    rootNavigatorKey.currentContext!.go(route);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '$label: route $route threw/overflowed');
  }
}

Future<void> _tapAndReturn(WidgetTester tester, String label, String openText, String backText) async {
  final finder = find.text(openText).first;
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: '$label: opening "$openText" threw/overflowed');

  final back = find.text(backText);
  if (back.evaluate().isNotEmpty) {
    await tester.ensureVisible(back);
    await tester.pumpAndSettle();
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: '$label: returning from "$openText" threw/overflowed');
  }
}

void main() {
  testWidgets('No layout overflow on a small phone (iPhone SE class, 375x667)', (tester) async {
    await _runAtSize(tester, 'small phone', 375, 667);
  });

  testWidgets('No layout overflow on a large phone/tablet (820x1180)', (tester) async {
    await _runAtSize(tester, 'large tablet', 820, 1180);
  });

  testWidgets('No layout overflow opening games and analyses on a small phone', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const GeneBreedApp());
    await tester.pumpAndSettle();

    rootNavigatorKey.currentContext!.go('/games');
    await tester.pumpAndSettle();
    for (final g in ['Trait Prediction', 'Gene Matching', 'DNA Puzzle', 'Chromosome Assembly', 'Mutation Challenge', 'Breeding Escape Room', 'Pedigree Puzzle', 'Genome Mapping']) {
      await _tapAndReturn(tester, 'small phone games', g, '← Back to Games');
    }

    rootNavigatorKey.currentContext!.go('/research-lab');
    await tester.pumpAndSettle();
    for (final a in ['Heritability & Genetic Advance', 'ANOVA (Randomized Block Design)', 'Line × Tester Analysis', 'QTL Mapping', 'Genome-Wide Association Study']) {
      await _tapAndReturn(tester, 'small phone research lab', a, '← Back to Lab');
    }

    rootNavigatorKey.currentContext!.go('/viva');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mendelian Genetics'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Foundation'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

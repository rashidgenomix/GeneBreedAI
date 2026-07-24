import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:genebreed_ai/main.dart';
import 'package:genebreed_ai/router.dart';

void main() {
  testWidgets('All 9 module routes navigate without error', (WidgetTester tester) async {
    await tester.pumpWidget(const GeneBreedApp());
    await tester.pumpAndSettle();

    const routes = [
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

    for (final route in routes) {
      rootNavigatorKey.currentContext!.go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'Route $route threw an exception');
    }
  });
}

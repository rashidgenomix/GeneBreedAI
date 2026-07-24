import 'package:flutter_test/flutter_test.dart';

import 'package:genebreed_ai/main.dart';

void main() {
  testWidgets('App launches and shows the home dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const GeneBreedApp());
    await tester.pumpAndSettle();

    expect(find.text('🧬 GeneBreed AI'), findsOneWidget);
    expect(find.text('Modules'), findsOneWidget);
  });
}

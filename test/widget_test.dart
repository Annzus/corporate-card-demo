import 'package:corporate_card_companion/app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigates between placeholder pages', (tester) async {
    await tester.pumpWidget(const BizCardDemoApp());

    expect(find.text('利用明細'), findsOneWidget);

    await tester.tap(find.byTooltip('デモ設定'));
    await tester.pumpAndSettle();

    expect(find.text('デモ設定'), findsOneWidget);
    expect(find.text('デモ専用'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('利用明細'), findsOneWidget);

    await tester.tap(find.text('詳細'));
    await tester.pumpAndSettle();

    expect(find.text('利用明細詳細'), findsOneWidget);
    expect(find.text('ID: demo'), findsOneWidget);
  });
}

import 'package:corporate_card_companion/features/settings/presentation/demo_settings_page.dart';
import 'package:corporate_card_companion/features/transactions/presentation/pages/transaction_detail_page.dart';
import 'package:corporate_card_companion/features/transactions/presentation/pages/transaction_list_page.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TransactionListPage(),
      routes: [
        GoRoute(
          path: 'transactions/:id',
          builder: (context, state) =>
              TransactionDetailPage(transactionId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const DemoSettingsPage(),
        ),
      ],
    ),
  ],
);

import 'package:corporate_card_companion/app/router.dart';
import 'package:corporate_card_companion/core/analytics/analytics_event.dart';
import 'package:corporate_card_companion/core/analytics/debug_analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BizCardDemoApp extends ConsumerStatefulWidget {
  const BizCardDemoApp({super.key});

  @override
  ConsumerState<BizCardDemoApp> createState() => _BizCardDemoAppState();
}

class _BizCardDemoAppState extends ConsumerState<BizCardDemoApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(debugAnalyticsServiceProvider.notifier)
          .track(
            AnalyticsEventName.appOpened,
            properties: {'brandId': 'business'},
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BizCard Demo',
      locale: const Locale('ja'),
      supportedLocales: const [Locale('ja')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

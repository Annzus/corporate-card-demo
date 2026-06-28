import 'package:corporate_card_companion/app/brand/brand_controller.dart';
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
            properties: {'brandId': ref.read(brandControllerProvider).id},
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final brand = ref.watch(brandControllerProvider);

    return MaterialApp.router(
      title: brand.displayName,
      locale: const Locale('ja'),
      supportedLocales: const [Locale('ja')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: brand.themeSeed),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

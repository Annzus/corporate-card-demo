import 'package:corporate_card_companion/app/brand/brand_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final brandControllerProvider = NotifierProvider<BrandController, BrandConfig>(
  BrandController.new,
);

class BrandController extends Notifier<BrandConfig> {
  @override
  BrandConfig build() => brandConfigs.first;

  void select(String brandId) {
    state = brandConfigs.firstWhere((brand) => brand.id == brandId);
  }
}

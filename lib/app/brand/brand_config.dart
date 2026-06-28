import 'package:flutter/material.dart';

enum BrandFeature { receiptUpload }

final class BrandConfig {
  const BrandConfig({
    required this.id,
    required this.displayName,
    required this.shortName,
    required this.cardLabel,
    required this.themeSeed,
    this.featureFlags = const {BrandFeature.receiptUpload},
  });

  final String id;
  final String displayName;
  final String shortName;
  final String cardLabel;
  final Color themeSeed;
  final Set<BrandFeature> featureFlags;
}

const brandConfigs = [
  BrandConfig(
    id: 'business',
    displayName: 'BizCard Business',
    shortName: 'Business',
    cardLabel: 'ビジネスカード',
    themeSeed: Colors.teal,
  ),
  BrandConfig(
    id: 'executive',
    displayName: 'BizCard Executive',
    shortName: 'Executive',
    cardLabel: 'エグゼクティブカード',
    themeSeed: Colors.indigo,
  ),
];

import 'dart:convert';

import 'package:corporate_card_companion/features/transactions/data/transaction_dto.dart';
import 'package:flutter/services.dart';

final class TransactionFixtureDataSource {
  TransactionFixtureDataSource({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  Future<List<TransactionDto>> load({required String brandId}) async {
    final path = switch (brandId) {
      'business' => 'assets/fixtures/transactions_business.json',
      'executive' => 'assets/fixtures/transactions_executive.json',
      _ => throw ArgumentError.value(brandId, 'brandId', 'Unsupported brand'),
    };
    final text = await _bundle.loadString(path);
    final rows = jsonDecode(text);
    if (rows is! List) {
      throw const FormatException('Fixture root must be a list');
    }
    return rows
        .cast<Map<String, Object?>>()
        .map(TransactionDto.fromJson)
        .toList();
  }
}

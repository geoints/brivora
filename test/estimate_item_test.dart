import 'package:flutter_test/flutter_test.dart';
import 'package:brivora/features/estimates/domain/models/estimate_item.dart';

void main() {
  test('EstimateItem recalculates total when quantity changes', () {
    final item = EstimateItem(
      id: 'test',
      projectId: 'project',
      name: 'Paint',
      category: 'material',
      quantity: 2,
      unit: 'л',
      unitPrice: 1500,
      totalPrice: 3000,
      comment: '',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    final updated = item.copyWith(quantity: 4);

    expect(updated.quantity, 4);
    expect(updated.unitPrice, 1500);
    expect(updated.totalPrice, 6000);
  });
}

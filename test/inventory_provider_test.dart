import 'package:flutter_test/flutter_test.dart';
import 'package:rssb_store_app/models/store_item.dart';
import 'package:rssb_store_app/models/stock_log.dart';

void main() {
  group('StoreItem Unit Tests', () {
    test('Low stock and out of stock flags work correctly', () {
      final inStockItem = StoreItem(
        id: '1',
        name: 'Tea Powder',
        quantity: 20.0,
        minAlertLevel: 5.0,
      );

      final lowStockItem = StoreItem(
        id: '2',
        name: 'Sugar',
        quantity: 3.0,
        minAlertLevel: 5.0,
      );

      final outOfStockItem = StoreItem(
        id: '3',
        name: 'Oil',
        quantity: 0.0,
        minAlertLevel: 5.0,
      );

      expect(inStockItem.isLowStock, false);
      expect(inStockItem.isOutOfStock, false);

      expect(lowStockItem.isLowStock, true);
      expect(lowStockItem.isOutOfStock, false);

      expect(outOfStockItem.isOutOfStock, true);
      expect(outOfStockItem.isLowStock, false);
    });

    test('Formatted quantity displays accurately', () {
      final itemInt = StoreItem(id: '1', name: 'Item A', quantity: 15.0, unit: 'Kg');
      final itemDouble = StoreItem(id: '2', name: 'Item B', quantity: 12.5, unit: 'Litres');

      expect(itemInt.formattedQuantity, '15 Kg');
      expect(itemDouble.formattedQuantity, '12.5 Litres');
    });

    test('StoreItem toMap and fromMap serialization', () {
      final original = StoreItem(
        id: '100',
        name: 'Toor Dal',
        quantity: 42.0,
        unit: 'Kg',
        minAlertLevel: 10.0,
        location: 'Rack B-2',
        category: 'Kitchen Supplies',
      );

      final map = original.toMap();
      final restored = StoreItem.fromMap(map);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.quantity, original.quantity);
      expect(restored.unit, original.unit);
      expect(restored.minAlertLevel, original.minAlertLevel);
      expect(restored.location, original.location);
    });

    test('StockLog serialization', () {
      final log = StockLog(
        id: 'l1',
        itemId: '100',
        itemName: 'Toor Dal',
        changeAmount: 5.0,
        newQuantity: 47.0,
        unit: 'Kg',
        action: 'Stock Addition',
      );

      final map = log.toMap();
      final restored = StockLog.fromMap(map);

      expect(restored.itemId, '100');
      expect(restored.changeAmount, 5.0);
      expect(restored.newQuantity, 47.0);
    });
  });
}

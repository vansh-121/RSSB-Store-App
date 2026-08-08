import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/store_item.dart';
import '../models/stock_log.dart';

class FirestoreService {
  FirebaseFirestore? get _db {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore instance not available: $e');
      return null;
    }
  }

  // Stream items live from Firestore for a given storeCode
  Stream<List<StoreItem>> streamItems(String storeCode) {
    try {
      final db = _db;
      if (db == null) return Stream.value([]);
      return db
          .collection('stores')
          .doc(storeCode.toUpperCase().trim())
          .collection('items')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => StoreItem.fromMap(doc.data(), doc.id)).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Stream activity logs live from Firestore
  Stream<List<StockLog>> streamLogs(String storeCode) {
    try {
      final db = _db;
      if (db == null) return Stream.value([]);
      return db
          .collection('stores')
          .doc(storeCode.toUpperCase().trim())
          .collection('logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => StockLog.fromMap(doc.data(), doc.id)).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  // Save or update store item
  Future<void> saveItem(String storeCode, StoreItem item) async {
    final db = _db;
    if (db == null) return;
    final docRef = db
        .collection('stores')
        .doc(storeCode.toUpperCase().trim())
        .collection('items')
        .doc(item.id);
    await docRef.set(item.toMap(), SetOptions(merge: true));
  }

  // Quick adjust quantity with log
  Future<void> updateQuantity({
    required String storeCode,
    required StoreItem item,
    required double delta,
    required String volunteerName,
  }) async {
    final db = _db;
    if (db == null) return;
    final double newQty = (item.quantity + delta).clamp(0.0, 99999.0);
    final String sanitizedCode = storeCode.toUpperCase().trim();

    final itemRef = db
        .collection('stores')
        .doc(sanitizedCode)
        .collection('items')
        .doc(item.id);

    final logRef = db
        .collection('stores')
        .doc(sanitizedCode)
        .collection('logs')
        .doc();

    final updatedItem = item.copyWith(
      quantity: newQty,
      lastUpdated: DateTime.now(),
      updatedBy: volunteerName,
    );

    final log = StockLog(
      id: logRef.id,
      itemId: item.id,
      itemName: item.name,
      changeAmount: delta,
      newQuantity: newQty,
      unit: item.unit,
      action: delta > 0 ? 'Stock Addition' : 'Stock Deduction',
      volunteerName: volunteerName,
      timestamp: DateTime.now(),
    );

    final batch = db.batch();
    batch.set(itemRef, updatedItem.toMap(), SetOptions(merge: true));
    batch.set(logRef, log.toMap());
    await batch.commit();
  }

  // Delete item
  Future<void> deleteItem(String storeCode, String itemId) async {
    final db = _db;
    if (db == null) return;
    await db
        .collection('stores')
        .doc(storeCode.toUpperCase().trim())
        .collection('items')
        .doc(itemId)
        .delete();
  }
}

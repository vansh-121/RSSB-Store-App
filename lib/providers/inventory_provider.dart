import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/store_item.dart';
import '../models/stock_log.dart';
import '../services/firestore_service.dart';

enum StockFilter { all, lowStock, inStock, outOfStock }

class InventoryProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  String _storeCode = 'RSSB-MAIN-STORE';
  String _volunteerName = 'Volunteer';
  String _searchQuery = '';
  StockFilter _selectedFilter = StockFilter.all;

  List<StoreItem> _items = [];
  List<StockLog> _logs = [];

  bool _isLoading = true;
  bool _isLiveSyncing = false;
  bool _isOnline = true;

  StreamSubscription? _itemsSub;
  StreamSubscription? _logsSub;
  StreamSubscription? _connectivitySub;

  // Getters
  String get storeCode => _storeCode;
  String get volunteerName => _volunteerName.isEmpty ? 'Seva Volunteer' : _volunteerName;
  bool get isVolunteerNameSet => _volunteerName.trim().isNotEmpty;
  String get searchQuery => _searchQuery;
  StockFilter get selectedFilter => _selectedFilter;
  bool get isLoading => _isLoading;
  bool get isLiveSyncing => _isLiveSyncing;
  bool get isOnline => _isOnline;
  List<StockLog> get logs => List.unmodifiable(_logs);

  final bool autoSync;

  InventoryProvider({this.autoSync = true}) {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    _storeCode = prefs.getString('store_code') ?? 'RSSB-MAIN-STORE';
    _volunteerName = prefs.getString('volunteer_name') ?? '';

    // Load local cached items first
    await _loadLocalItems(prefs);
    await _loadLocalLogs(prefs);

    _isLoading = false;
    notifyListeners();

    // Start live sync & connectivity monitoring
    _connectRealtimeSync();

    try {
      _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
        final hasNet = !results.contains(ConnectivityResult.none);
        if (_isOnline != hasNet) {
          _isOnline = hasNet;
          notifyListeners();
        }
      });
    } catch (_) {}
  }

  void setStoreCode(String newCode) async {
    if (newCode.trim().isEmpty) return;
    _storeCode = newCode.toUpperCase().trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('store_code', _storeCode);
    notifyListeners();
    _connectRealtimeSync();
  }

  void setVolunteerName(String name) async {
    if (name.trim().isEmpty) return;
    _volunteerName = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('volunteer_name', _volunteerName);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setFilter(StockFilter filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Realtime Cloud Sync Connection
  void _connectRealtimeSync() {
    if (!autoSync) return;
    _itemsSub?.cancel();
    _logsSub?.cancel();

    try {
      _itemsSub = _firestoreService.streamItems(_storeCode).listen((cloudItems) {
        if (cloudItems.isNotEmpty) {
          _items = cloudItems;
          _isLiveSyncing = true;
          _saveLocalItems();
          notifyListeners();
        }
      }, onError: (e) {
        _isLiveSyncing = false;
        notifyListeners();
      });

      _logsSub = _firestoreService.streamLogs(_storeCode).listen((cloudLogs) {
        if (cloudLogs.isNotEmpty) {
          _logs = cloudLogs;
          _saveLocalLogs();
          notifyListeners();
        }
      }, onError: (_) {});
    } catch (e) {
      _isLiveSyncing = false;
      notifyListeners();
    }
  }

  // Filtered & Searched Items
  List<StoreItem> get filteredItems {
    return _items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery) ||
          item.location.toLowerCase().contains(_searchQuery) ||
          item.category.toLowerCase().contains(_searchQuery);

      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case StockFilter.lowStock:
          return item.isLowStock;
        case StockFilter.inStock:
          return item.quantity > item.minAlertLevel;
        case StockFilter.outOfStock:
          return item.isOutOfStock;
        case StockFilter.all:
        default:
          return true;
      }
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // Stats
  int get totalItemsCount => _items.length;

  double get totalQuantitySum =>
      _items.fold(0.0, (sum, item) => sum + item.quantity);

  int get lowStockCount => _items.where((item) => item.isLowStock).length;

  int get outOfStockCount => _items.where((item) => item.isOutOfStock).length;

  List<StoreItem> get lowStockItems =>
      _items.where((item) => item.isLowStock || item.isOutOfStock).toList();

  // Item Actions (Add / Edit)
  Future<void> saveStoreItem(StoreItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    final isNew = index == -1;

    final updatedItem = item.copyWith(
      lastUpdated: DateTime.now(),
      updatedBy: _volunteerName,
    );

    if (isNew) {
      _items.add(updatedItem);
    } else {
      _items[index] = updatedItem;
    }

    final log = StockLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: updatedItem.id,
      itemName: updatedItem.name,
      changeAmount: updatedItem.quantity,
      newQuantity: updatedItem.quantity,
      unit: updatedItem.unit,
      action: isNew ? 'Added New Item' : 'Updated Item Details',
      volunteerName: _volunteerName,
    );

    _logs.insert(0, log);
    _saveLocalItems();
    _saveLocalLogs();
    notifyListeners();

    // Sync cloud
    try {
      await _firestoreService.saveItem(_storeCode, updatedItem);
    } catch (_) {}
  }

  // 1-Tap Quick Adjust Stock Quantity (+ or -)
  Future<void> adjustQuantity(StoreItem item, double delta) async {
    final newQty = (item.quantity + delta).clamp(0.0, 99999.0);
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;

    final updatedItem = item.copyWith(
      quantity: newQty,
      lastUpdated: DateTime.now(),
      updatedBy: _volunteerName,
    );

    _items[index] = updatedItem;

    final log = StockLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itemId: item.id,
      itemName: item.name,
      changeAmount: delta,
      newQuantity: newQty,
      unit: item.unit,
      action: delta > 0 ? 'Stock Addition' : 'Stock Deduction',
      volunteerName: _volunteerName,
    );

    _logs.insert(0, log);
    _saveLocalItems();
    _saveLocalLogs();
    notifyListeners();

    // Cloud firestore update
    try {
      await _firestoreService.updateQuantity(
        storeCode: _storeCode,
        item: item,
        delta: delta,
        volunteerName: _volunteerName,
      );
    } catch (_) {}
  }

  // Delete Item
  Future<void> deleteItem(String itemId) async {
    final itemIndex = _items.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      final deletedItem = _items[itemIndex];
      final log = StockLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemId: itemId,
        itemName: deletedItem.name,
        changeAmount: 0,
        newQuantity: 0,
        unit: deletedItem.unit,
        action: 'Item Deleted',
        volunteerName: volunteerName,
      );
      _logs.insert(0, log);
      _saveLocalLogs();
    }

    _items.removeWhere((item) => item.id == itemId);
    _saveLocalItems();
    notifyListeners();

    try {
      await _firestoreService.deleteItem(_storeCode, itemId);
    } catch (_) {}
  }

  // Reset to default sample RSSB store items
  Future<void> resetToSampleData() async {
    _items = _getInitialSampleItems();
    _saveLocalItems();
    notifyListeners();

    for (var item in _items) {
      try {
        await _firestoreService.saveItem(_storeCode, item);
      } catch (_) {}
    }
  }

  // Clear all inventory items and logs
  Future<void> clearAllItems() async {
    _items.clear();
    _logs.clear();
    await _saveLocalItems();
    await _saveLocalLogs();
    notifyListeners();
  }

  // Local Storage Helpers
  Future<void> _saveLocalItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _items.map((i) => i.toMap()).toList();
    await prefs.setString('cached_items_$_storeCode', jsonEncode(jsonList));
  }

  Future<void> _saveLocalLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _logs.take(50).map((l) => l.toMap()).toList();
    await prefs.setString('cached_logs_$_storeCode', jsonEncode(jsonList));
  }

  Future<void> _loadLocalItems(SharedPreferences prefs) async {
    final rawJson = prefs.getString('cached_items_$_storeCode');
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List list = jsonDecode(rawJson);
        final loaded = list.map((e) => StoreItem.fromMap(e as Map<String, dynamic>)).toList();
        // Purge any previously cached sample items automatically
        _items = loaded.where((item) {
          final isSampleId = ['1', '2', '3', '4', '5', '6', '7', '8'].contains(item.id);
          final isSampleName = item.name.contains('Chai Patti') ||
              item.name.contains('Cheeni') ||
              item.name.contains('Sarson Ka Tel') ||
              item.name.contains('Safai Kapda') ||
              item.name.contains('Arhar') ||
              item.name.contains('Dari/Mat');
          return !isSampleId && !isSampleName;
        }).toList();
        await _saveLocalItems();
        return;
      } catch (_) {}
    }
    // Start with a clean, empty store catalog
    _items = [];
    await _saveLocalItems();
  }

  Future<void> _loadLocalLogs(SharedPreferences prefs) async {
    final rawJson = prefs.getString('cached_logs_$_storeCode');
    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List list = jsonDecode(rawJson);
        _logs = list.map((e) => StockLog.fromMap(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
  }

  List<StoreItem> _getInitialSampleItems() {
    return [];
  }

  @override
  void dispose() {
    _itemsSub?.cancel();
    _logsSub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}

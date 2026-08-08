import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/store_item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import '../widgets/metric_card.dart';
import '../widgets/store_code_dialog.dart';
import 'add_edit_item_screen.dart';
import 'stock_history_screen.dart';
import 'low_stock_report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStoreCodeDialog() {
    showDialog(
      context: context,
      builder: (context) => const StoreCodeDialog(),
    );
  }

  void _openAddEditScreen([StoreItem? item]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditItemScreen(initialItem: item),
      ),
    );
  }

  void _showDeleteDialog(StoreItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Store Item?'),
        content: Text('Are you sure you want to remove "${item.name}" from inventory?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<InventoryProvider>(context, listen: false)
                  .deleteItem(item.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "${item.name}"'),
                  backgroundColor: AppTheme.dangerRed,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = provider.filteredItems;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store_mall_directory, size: 22),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'RSSB Store',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Live Sync Store Code Badge
          Flexible(
            child: InkWell(
              onTap: _openStoreCodeDialog,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(right: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.isLiveSyncing ? Icons.sensors : Icons.sync,
                      color: provider.isLiveSyncing ? Colors.amberAccent : Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        provider.storeCode,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'history') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StockHistoryScreen()),
                );
              } else if (val == 'report') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LowStockReportScreen()),
                );
              } else if (val == 'clear') {
                provider.clearAllItems();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cleared all store items'),
                    backgroundColor: AppTheme.warningOrange,
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 18),
                    SizedBox(width: 8),
                    Text('Stock Activity Trail'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.assignment_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Low Stock Report'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep_outlined, color: AppTheme.dangerRed, size: 18),
                    SizedBox(width: 8),
                    Text('Clear All Store Items', style: TextStyle(color: AppTheme.dangerRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryTeal),
              accountName: Text(
                'RSSB Store & Inventory',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(
                'Connected Store Code: ${provider.storeCode}\nUser: ${provider.volunteerName}',
                style: GoogleFonts.inter(fontSize: 12),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.storefront, color: AppTheme.primaryTeal, size: 36),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Inventory Catalog'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Stock Activity Trail'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockHistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange),
              title: const Text('Low Stock Requisition'),
              trailing: provider.lowStockCount > 0
                  ? Badge(label: Text('${provider.lowStockCount}'))
                  : null,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LowStockReportScreen()));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.sync_alt),
              title: const Text('Switch Store Code / User'),
              subtitle: Text('Code: ${provider.storeCode}'),
              onTap: () {
                Navigator.pop(context);
                _openStoreCodeDialog();
              },
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // Offline Internet Connection Warning Banner
          if (!provider.isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: AppTheme.warningOrange,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Please connect to internet to see live data updates.',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Top Statistics Dashboard Grid (KPIs)
          Container(
            padding: const EdgeInsets.all(14.0),
            color: isDark ? AppTheme.darkSurface : Colors.teal.shade50.withOpacity(0.4),
            child: Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: 'Total Items',
                    value: '${provider.totalItemsCount}',
                    subtitle: 'Unique Store Items',
                    icon: Icons.inventory_2_outlined,
                    color: AppTheme.primaryTeal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    title: 'Low Stock',
                    value: '${provider.lowStockCount}',
                    subtitle: 'Items Need Refill',
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.warningOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LowStockReportScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    title: 'Out of Stock',
                    value: '${provider.outOfStockCount}',
                    subtitle: 'Zero Stock Count',
                    icon: Icons.cancel_outlined,
                    color: AppTheme.dangerRed,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar & Filter Chips Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => provider.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search items by name, shelf, or category...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        label: 'All Items (${provider.totalItemsCount})',
                        filter: StockFilter.all,
                        selected: provider.selectedFilter == StockFilter.all,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'Low Stock (${provider.lowStockCount})',
                        filter: StockFilter.lowStock,
                        selected: provider.selectedFilter == StockFilter.lowStock,
                        color: AppTheme.warningOrange,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'In Stock (${provider.totalItemsCount - provider.lowStockCount - provider.outOfStockCount})',
                        filter: StockFilter.inStock,
                        selected: provider.selectedFilter == StockFilter.inStock,
                        color: AppTheme.successGreen,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        context,
                        label: 'Out of Stock (${provider.outOfStockCount})',
                        filter: StockFilter.outOfStock,
                        selected: provider.selectedFilter == StockFilter.outOfStock,
                        color: AppTheme.dangerRed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Inventory List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No matching store items found',
                              style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _openAddEditScreen(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add New Item'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ItemCard(
                            item: item,
                            onAdjustQuantity: (delta) {
                              provider.adjustQuantity(item, delta);
                            },
                            onEdit: () => _openAddEditScreen(item),
                            onDelete: () => _showDeleteDialog(item),
                          );
                        },
                      ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEditScreen(),
        icon: const Icon(Icons.add),
        label: Text(
          'Add Item',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required StockFilter filter,
    required bool selected,
    Color? color,
  }) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final activeColor = color ?? AppTheme.primaryTeal;

    return FilterChip(
      selected: selected,
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? Colors.white : activeColor,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      selectedColor: activeColor,
      backgroundColor: activeColor.withOpacity(0.08),
      side: BorderSide(color: activeColor.withOpacity(0.3)),
      onSelected: (_) => provider.setFilter(filter),
    );
  }
}

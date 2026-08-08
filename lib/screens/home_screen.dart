import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/store_item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVolunteerNameOnLaunch();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _checkVolunteerNameOnLaunch() {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    if (!provider.isVolunteerNameSet) {
      _showVolunteerNameDialog(isFirstTime: true);
    }
  }

  void _showVolunteerNameDialog({bool isFirstTime = false}) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final textController = TextEditingController(
        text: isFirstTime ? '' : (provider.isVolunteerNameSet ? provider.volunteerName : ''));

    showDialog(
      context: context,
      barrierDismissible: !isFirstTime,
      builder: (ctx) => PopScope(
        canPop: !isFirstTime,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline, color: AppTheme.primaryTeal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFirstTime ? 'Seva Volunteer Login' : 'Update Volunteer Name',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Your name will be saved forever',
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please enter your name. Every item addition, edit, or quantity change will be logged under your name.',
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
              ),
              const SizedBox(height: 16),
              Text(
                'YOUR SEVA VOLUNTEER NAME *',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: textController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Ramesh Kumar',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ],
          ),
          actions: [
            if (!isFirstTime)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
            ElevatedButton(
              onPressed: () {
                final name = textController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your name to continue'),
                      backgroundColor: AppTheme.dangerRed,
                    ),
                  );
                  return;
                }
                provider.setVolunteerName(name);
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Welcome $name! Name saved permanently.'),
                    backgroundColor: AppTheme.primaryTeal,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isFirstTime ? 'Save & Start' : 'Save Name'),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddEditScreen([StoreItem? item]) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    if (!provider.isVolunteerNameSet) {
      _showVolunteerNameDialog(isFirstTime: true);
      return;
    }

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
        title: const Text('Delete Item?'),
        content: Text('Remove "${item.name}" from store inventory?'),
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
    final items = provider.filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RSSB Store',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          // Volunteer Profile Name Chip (Tap to change name)
          InkWell(
            onTap: () => _showVolunteerNameDialog(isFirstTime: false),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Text(
                      provider.isVolunteerNameSet ? provider.volunteerName : 'Set Name',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
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

          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'name') {
                _showVolunteerNameDialog(isFirstTime: false);
              } else if (val == 'history') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StockHistoryScreen()),
                );
              } else if (val == 'report') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LowStockReportScreen()),
                );
              } else if (val == 'clear') {
                provider.clearAllItems();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, size: 18),
                    const SizedBox(width: 8),
                    Text('Volunteer: ${provider.volunteerName}'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 18),
                    SizedBox(width: 8),
                    Text('Activity Trail'),
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
                    Icon(Icons.delete_sweep_outlined, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Text('Clear All Items', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Column(
        children: [
          // Offline Warning Banner
          if (!provider.isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: AppTheme.warningOrange,
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline mode - connect to internet for live sync.',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Simple Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => provider.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search store items...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearchQuery('');
                        },
                      )
                    : null,
              ),
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
                            Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              'No store items found',
                              style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _openAddEditScreen(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Item'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ItemCard(
                            item: item,
                            onAdjustQuantity: (delta) {
                              if (!provider.isVolunteerNameSet) {
                                _showVolunteerNameDialog(isFirstTime: true);
                                return;
                              }
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

      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddEditScreen(),
        tooltip: 'Add Store Item',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

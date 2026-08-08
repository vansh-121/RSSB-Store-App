import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';

class LowStockReportScreen extends StatelessWidget {
  const LowStockReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final lowStockItems = provider.lowStockItems;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    void copyReorderList() {
      if (lowStockItems.isEmpty) return;

      final buffer = StringBuffer();
      buffer.writeln('📋 *RSSB STORE REORDER REQUISITION LIST*');
      buffer.writeln('Generated on: ${DateTime.now().toString().split('.')[0]}');
      buffer.writeln('-----------------------------------');

      for (var i = 0; i < lowStockItems.length; i++) {
        final item = lowStockItems[i];
        final status = item.isOutOfStock ? '[OUT OF STOCK]' : '[LOW STOCK]';
        buffer.writeln(
            '${i + 1}. ${item.name} - Current: ${item.formattedQuantity} (Alert Min: ${item.minAlertLevel.toInt()} ${item.unit}) $status | Location: ${item.location}');
      }

      buffer.writeln('-----------------------------------');
      buffer.writeln('Please fulfill store refill requisition.');

      Clipboard.setData(ClipboardData(text: buffer.toString()));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reorder requisition list copied to clipboard!'),
          backgroundColor: AppTheme.primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Low Stock Requisition'),
        actions: [
          if (lowStockItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.copy_all_outlined),
              tooltip: 'Copy Reorder List',
              onPressed: copyReorderList,
            ),
        ],
      ),
      body: lowStockItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.task_alt, size: 64, color: AppTheme.successGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Inventory is Healthy!',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'All store items are above minimum alert thresholds.',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.warningOrange, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${lowStockItems.length} Items Need Refill',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warningOrange,
                              ),
                            ),
                            Text(
                              'Requisition these items from Central Beas Store / Supplier.',
                              style: GoogleFonts.inter(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[800]),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: copyReorderList,
                        icon: const Icon(Icons.copy, size: 16),
                        label: const Text('Copy'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warningOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: lowStockItems.length,
                    itemBuilder: (context, index) {
                      final item = lowStockItems[index];
                      final isOut = item.isOutOfStock;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: (isOut ? AppTheme.dangerRed : AppTheme.warningOrange).withOpacity(0.15),
                            child: Icon(
                              isOut ? Icons.cancel_outlined : Icons.warning_amber_rounded,
                              color: isOut ? AppTheme.dangerRed : AppTheme.warningOrange,
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Location: ${item.location} | Alert Threshold: ${item.minAlertLevel.toInt()} ${item.unit}',
                            style: GoogleFonts.inter(fontSize: 12),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                item.formattedQuantity,
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isOut ? AppTheme.dangerRed : AppTheme.warningOrange,
                                ),
                              ),
                              Text(
                                isOut ? 'OUT OF STOCK' : 'LOW STOCK',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isOut ? AppTheme.dangerRed : AppTheme.warningOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

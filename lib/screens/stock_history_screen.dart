import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';

class StockHistoryScreen extends StatelessWidget {
  const StockHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final logs = provider.logs;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Activity Trail'),
      ),
      body: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'No stock history recorded yet',
                    style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Adjust stock quantities to see real-time log activity',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final isAddition = log.changeAmount > 0;
                final color = isAddition ? AppTheme.successGreen : AppTheme.dangerRed;
                final formattedDate =
                    DateFormat('dd MMM yyyy, hh:mm a').format(log.timestamp);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isAddition ? Icons.add_circle_outline : Icons.remove_circle_outline,
                        color: color,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            log.itemName,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '${isAddition ? '+' : ''}${log.changeAmount % 1 == 0 ? log.changeAmount.toInt() : log.changeAmount.toStringAsFixed(1)} ${log.unit}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Action: ${log.action}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'New Balance: ${log.newQuantity % 1 == 0 ? log.newQuantity.toInt() : log.newQuantity.toStringAsFixed(1)} ${log.unit}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'By ${log.volunteerName}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.primaryTeal,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: isDark ? Colors.grey[500] : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

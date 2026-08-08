import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/store_item.dart';
import '../theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final StoreItem item;
  final Function(double delta) onAdjustQuantity;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ItemCard({
    super.key,
    required this.item,
    required this.onAdjustQuantity,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor = AppTheme.successGreen;
    String statusText = 'IN STOCK';
    IconData statusIcon = Icons.check_circle_outline;

    if (item.isOutOfStock) {
      statusColor = AppTheme.dangerRed;
      statusText = 'OUT OF STOCK';
      statusIcon = Icons.cancel_outlined;
    } else if (item.isLowStock) {
      statusColor = AppTheme.warningOrange;
      statusText = 'LOW STOCK';
      statusIcon = Icons.warning_amber_rounded;
    }

    final formattedTime = DateFormat('dd MMM, hh:mm a').format(item.lastUpdated);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Name, Status Badge, Options
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, color: statusColor, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item.category.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isDark ? Colors.teal[800] : Colors.teal[50])?.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.category,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.teal[200] : AppTheme.primaryTeal,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  icon: Icon(Icons.more_vert, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit Item'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 18),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle Section: Location, Alert Level, Notes
            Row(
              children: [
                Icon(Icons.door_sliding_outlined, size: 15, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  item.location.isEmpty ? 'Main Rack' : item.location,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.notifications_none_outlined, size: 15, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Min: ${item.minAlertLevel.toInt()} ${item.unit}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),

            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.notes,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const Divider(height: 20),

            // Bottom Action Bar: Quantity Display & 1-Tap Adjuster (+ / -)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AVAILABLE STOCK',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      item.formattedQuantity,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Deduct Button (-)
                    IconButton.filledTonal(
                      onPressed: item.quantity <= 0 ? null : () => onAdjustQuantity(-1.0),
                      icon: const Icon(Icons.remove, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.12),
                        foregroundColor: Colors.red[700],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      tooltip: 'Deduct 1 ${item.unit}',
                    ),
                    const SizedBox(width: 8),
                    // Quick add +5 button
                    OutlinedButton(
                      onPressed: () => onAdjustQuantity(5.0),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: AppTheme.primaryTeal.withOpacity(0.4)),
                      ),
                      child: Text(
                        '+5',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add Button (+1)
                    IconButton.filled(
                      onPressed: () => onAdjustQuantity(1.0),
                      icon: const Icon(Icons.add, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      tooltip: 'Add 1 ${item.unit}',
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Last updated $formattedTime by ${item.updatedBy}',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

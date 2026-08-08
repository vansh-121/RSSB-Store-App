import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    Color statusColor = AppTheme.primaryTeal;
    if (item.isOutOfStock) {
      statusColor = AppTheme.dangerRed;
    } else if (item.isLowStock) {
      statusColor = AppTheme.warningOrange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              // Left: Item Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 12, color: AppTheme.primaryTeal),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            'Last changed by ${item.updatedBy.isEmpty ? "Volunteer" : item.updatedBy}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.teal[200] : AppTheme.primaryTeal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.location.isNotEmpty) ...[
                          Icon(Icons.location_on_outlined, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(
                            item.location,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (item.isLowStock || item.isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.isOutOfStock ? 'OUT OF STOCK' : 'LOW STOCK',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right: Quantity & 1-Tap +/- Controls
              Row(
                children: [
                  // Minus Button
                  IconButton.filledTonal(
                    onPressed: item.quantity <= 0 ? null : () => onAdjustQuantity(-1.0),
                    icon: const Icon(Icons.remove, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.12),
                      foregroundColor: AppTheme.dangerRed,
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  // Quantity Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    constraints: const BoxConstraints(minWidth: 55),
                    child: Column(
                      children: [
                        Text(
                          item.quantity % 1 == 0 ? '${item.quantity.toInt()}' : item.quantity.toStringAsFixed(1),
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          item.unit,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Plus Button
                  IconButton.filled(
                    onPressed: () => onAdjustQuantity(1.0),
                    icon: const Icon(Icons.add, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(36, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') onEdit();
                      if (val == 'delete') onDelete();
                    },
                    icon: Icon(Icons.more_vert, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    padding: EdgeInsets.zero,
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
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
            ],
          ),
        ),
      ),
    );
  }
}

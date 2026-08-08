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

    final String personName = item.updatedBy.isEmpty ? "Seva Volunteer" : item.updatedBy;
    final Color secondaryTextColor = isDark ? Colors.white70 : Colors.black87;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Row: Left Info & Right Quantity Controls
              Row(
                children: [
                  // Left Side: Item Name & Location / Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.location.isNotEmpty) ...[
                              Icon(Icons.location_on_outlined, size: 14, color: secondaryTextColor),
                              const SizedBox(width: 2),
                              Text(
                                item.location,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryTextColor,
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

                  // Right Side: Quantity Display & 1-Tap +/- Controls
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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        constraints: const BoxConstraints(minWidth: 50),
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
                                fontWeight: FontWeight.w600,
                                color: secondaryTextColor,
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
                        icon: Icon(Icons.more_vert, size: 18, color: secondaryTextColor),
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

              const SizedBox(height: 8),
              Divider(height: 1, thickness: 0.5, color: isDark ? Colors.white12 : Colors.black12),
              const SizedBox(height: 6),

              // Separate Full-Width Line: Last Changed By [Person Name]
              Row(
                children: [
                  Icon(
                    Icons.account_circle_outlined,
                    size: 14,
                    color: isDark ? AppTheme.primaryLightTeal : AppTheme.primaryTeal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last changed by ',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                  Text(
                    personName,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppTheme.primaryLightTeal : AppTheme.primaryTeal,
                    ),
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

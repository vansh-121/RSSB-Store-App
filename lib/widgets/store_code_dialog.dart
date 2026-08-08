import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';

class StoreCodeDialog extends StatefulWidget {
  const StoreCodeDialog({super.key});

  @override
  State<StoreCodeDialog> createState() => _StoreCodeDialogState();
}

class _StoreCodeDialogState extends State<StoreCodeDialog> {
  late TextEditingController _codeController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    _codeController = TextEditingController(text: provider.storeCode);
    _nameController = TextEditingController(text: provider.volunteerName);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sync, color: AppTheme.primaryTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Multi-User Live Sync',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Connect devices together',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share this Store Room Code with all 10 volunteers so everyone sees exact real-time live stock data.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            // Store Code Field
            Text(
              'STORE ROOM CODE',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'e.g. RSSB-MAIN-STORE',
                prefixIcon: Icon(Icons.meeting_room_outlined),
              ),
            ),
            const SizedBox(height: 16),

            // Volunteer Name Field
            Text(
              'YOUR VOLUNTEER NAME',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'e.g. Seva Volunteer',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final code = _codeController.text.trim();
            final name = _nameController.text.trim();
            if (code.isNotEmpty) provider.setStoreCode(code);
            if (name.isNotEmpty) provider.setVolunteerName(name);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Connected to Store Code: ${provider.storeCode}'),
                backgroundColor: AppTheme.primaryTeal,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Connect & Sync'),
        ),
      ],
    );
  }
}

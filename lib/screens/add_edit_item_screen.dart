import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/store_item.dart';
import '../providers/inventory_provider.dart';
import '../theme/app_theme.dart';

class AddEditItemScreen extends StatefulWidget {
  final StoreItem? initialItem;

  const AddEditItemScreen({super.key, this.initialItem});

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _minAlertController;
  late TextEditingController _locationController;
  late TextEditingController _categoryController;
  late TextEditingController _notesController;

  String _selectedUnit = 'Kg';

  final List<String> _commonUnits = [
    'Kg',
    'Litres',
    'Packs',
    'Pcs',
    'Boxes',
    'Bags',
    'Rolls',
    'Sets',
    'Cartons',
  ];

  final List<String> _categories = [
    'Kitchen Supplies',
    'General Store',
    'Seva Equipment',
    'Stationery',
    'Cleaning Material',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
        text: item != null ? item.quantity.toString() : '10');
    _minAlertController = TextEditingController(
        text: item != null ? item.minAlertLevel.toString() : '5');
    _locationController = TextEditingController(text: item?.location ?? 'Rack A');
    _categoryController = TextEditingController(text: item?.category ?? 'Kitchen Supplies');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _selectedUnit = item?.unit ?? 'Kg';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minAlertController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<InventoryProvider>(context, listen: false);

    final String itemId = widget.initialItem?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final newItem = StoreItem(
      id: itemId,
      name: _nameController.text.trim(),
      quantity: double.tryParse(_quantityController.text.trim()) ?? 0.0,
      unit: _selectedUnit,
      minAlertLevel: double.tryParse(_minAlertController.text.trim()) ?? 5.0,
      location: _locationController.text.trim().isEmpty
          ? 'Main Rack'
          : _locationController.text.trim(),
      category: _categoryController.text.trim().isEmpty
          ? 'General Store'
          : _categoryController.text.trim(),
      notes: _notesController.text.trim(),
      updatedBy: provider.volunteerName,
    );

    provider.saveStoreItem(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.initialItem == null
            ? 'Item added successfully'
            : 'Item updated successfully'),
        backgroundColor: AppTheme.primaryTeal,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Store Item' : 'Add Store Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Name Field
              Text(
                'ITEM NAME *',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                autofocus: !isEditing,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Tea Powder, Sugar, Pulses',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity & Unit Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT QUANTITY *',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            hintText: '0',
                            prefixIcon: Icon(Icons.numbers_outlined),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Enter qty';
                            }
                            if (double.tryParse(val.trim()) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UNIT *',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          items: _commonUnits.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedUnit = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Minimum Alert Level & Storage Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOW STOCK ALERT LEVEL',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _minAlertController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '5',
                            prefixIcon: Icon(Icons.warning_amber_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SHELF / RACK LOCATION',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _locationController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'Rack A-1',
                            prefixIcon: Icon(Icons.door_sliding_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Selection
              Text(
                'CATEGORY / GROUP',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 6),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: _categoryController.text),
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _categories;
                  }
                  return _categories.where((cat) =>
                      cat.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (selection) {
                  _categoryController.text = selection;
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  _categoryController = controller;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Kitchen Supplies, General Store',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Notes / Remarks
              Text(
                'NOTES / REMARKS',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Any extra details or supplier notes...',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: 28),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    isEditing ? 'Update Item' : 'Save Item to Store',
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

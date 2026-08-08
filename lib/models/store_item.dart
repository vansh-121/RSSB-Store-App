class StoreItem {
  final String id;
  final String name;
  final double quantity;
  final String unit; // e.g. Kg, Litres, Packs, Pcs, Boxes, Bags, Rolls, Sets
  final double minAlertLevel;
  final String location; // Rack / Shelf / Room
  final String category; // e.g. Kitchen/Langar, General Store, Seva Supplies, Stationary
  final String notes;
  final DateTime lastUpdated;
  final String updatedBy;

  StoreItem({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit = 'Pcs',
    this.minAlertLevel = 5.0,
    this.location = 'Main Rack',
    this.category = 'General Store',
    this.notes = '',
    DateTime? lastUpdated,
    this.updatedBy = 'Volunteer',
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  bool get isLowStock => quantity > 0 && quantity <= minAlertLevel;
  bool get isOutOfStock => quantity <= 0;

  String get formattedQuantity {
    if (quantity % 1 == 0) {
      return '${quantity.toInt()} $unit';
    }
    return '${quantity.toStringAsFixed(1)} $unit';
  }

  StoreItem copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    double? minAlertLevel,
    String? location,
    String? category,
    String? notes,
    DateTime? lastUpdated,
    String? updatedBy,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      minAlertLevel: minAlertLevel ?? this.minAlertLevel,
      location: location ?? this.location,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'minAlertLevel': minAlertLevel,
      'location': location,
      'category': category,
      'notes': notes,
      'lastUpdated': lastUpdated.toIso8601String(),
      'updatedBy': updatedBy,
    };
  }

  factory StoreItem.fromMap(Map<String, dynamic> map, [String? docId]) {
    return StoreItem(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'Pcs',
      minAlertLevel: (map['minAlertLevel'] as num?)?.toDouble() ?? 5.0,
      location: map['location'] ?? 'Main Rack',
      category: map['category'] ?? 'General Store',
      notes: map['notes'] ?? '',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedBy: map['updatedBy'] ?? 'Volunteer',
    );
  }
}

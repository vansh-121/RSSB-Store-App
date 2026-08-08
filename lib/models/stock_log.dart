class StockLog {
  final String id;
  final String itemId;
  final String itemName;
  final double changeAmount; // e.g. +5.0 or -2.0
  final double newQuantity;
  final String unit;
  final String action; // e.g. "Added", "Deducted", "Initial", "Edit"
  final String volunteerName;
  final DateTime timestamp;

  StockLog({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.changeAmount,
    required this.newQuantity,
    this.unit = 'Pcs',
    required this.action,
    this.volunteerName = 'Volunteer',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'itemId': itemId,
      'itemName': itemName,
      'changeAmount': changeAmount,
      'newQuantity': newQuantity,
      'unit': unit,
      'action': action,
      'volunteerName': volunteerName,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory StockLog.fromMap(Map<String, dynamic> map, [String? docId]) {
    return StockLog(
      id: docId ?? map['id'] ?? '',
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      changeAmount: (map['changeAmount'] as num?)?.toDouble() ?? 0.0,
      newQuantity: (map['newQuantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] ?? 'Pcs',
      action: map['action'] ?? 'Update',
      volunteerName: map['volunteerName'] ?? 'Volunteer',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

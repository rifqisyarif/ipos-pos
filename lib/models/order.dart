class OrderStatus {
  static const pending = 'pending';
  static const confirmed = 'confirmed';
  static const preparing = 'preparing';
  static const ready = 'ready';
  static const served = 'served';

  static const steps = [pending, confirmed, preparing, ready, served];

  static int stepIndex(String status) => steps.indexOf(status);
}

class Order {
  final String id;
  final String tableId;
  final String status;
  final double total;
  final int? estimatedMinutes;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.tableId,
    required this.status,
    required this.total,
    this.estimatedMinutes,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        tableId: json['table_id'],
        status: json['status'],
        total: (json['total'] as num).toDouble(),
        estimatedMinutes: json['estimated_minutes'],
        createdAt: DateTime.parse(json['created_at']),
      );
}

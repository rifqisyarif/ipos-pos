import 'package:hive/hive.dart';

class OrderQueueService {
  static const _boxName = 'offline_orders';

  Future<void> addOrder(Map<String, dynamic> order) async {
    final box = Hive.box(_boxName);

    final orders = List<Map<String, dynamic>>.from(
      (box.get('queue') ?? []).map(
        (e) => Map<String, dynamic>.from(e),
      ),
    );

    orders.add(order);

    await box.put('queue', orders);
  }

  List<Map<String, dynamic>> getQueuedOrders() {
    final box = Hive.box(_boxName);

    return List<Map<String, dynamic>>.from(
      (box.get('queue') ?? []).map(
        (e) => Map<String, dynamic>.from(e),
      ),
    );
  }

  Future<void> removeOrder(String localId) async {
    final box = Hive.box(_boxName);

    final orders = getQueuedOrders();

    orders.removeWhere(
      (e) => e['local_id'] == localId,
    );

    await box.put('queue', orders);
  }
}

import '../entity/order.dart';
import '../entity/order_detail.dart';
import '../repository/database_helper.dart';
import 'cart_manager.dart';

class OrderService {
  static Future<void> checkout({
    required int tableId,
    required int waiterId,
    required CartManager cartManager,
  }) async {

    final db = await DatabaseHelper.instance.database;

    double totalAmount = cartManager.cart.length * 50000;

    final order = Order(
      tableId: tableId,
      waiterId: waiterId,
      totalAmount: totalAmount,
      status: "Pending",
      createdAt: DateTime.now(),
    );

    int orderId = await db.insert('MealOrders', order.toMap());

    for (var item in cartManager.cart) {
      final newItem = OrderDetail(
        orderId: orderId,
        productId: item.productId,
        quantity: item.quantity,
        note: item.note,
      );

      await db.insert('OrderDetails', newItem.toMap());
    }

    await db.update(
      'DiningTables',
      {'Status': 'Occupied'},
      where: 'TableID = ?',
      whereArgs: [tableId],
    );

    cartManager.clear();
  }
}

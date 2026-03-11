import 'package:project/entity/order.dart';

// Class chứa chi tiết từng món ăn kèm tên món
class OrderDetailItem {
  final int quantity;
  final String productName;
  final String? note;

  OrderDetailItem({
    required this.quantity,
    required this.productName,
    this.note,
  });
}

// Class chứa toàn bộ thông tin của 1 thẻ đơn hàng hiển thị trên UI
class OrderQueueItem {
  final Order order;
  final String tableName;
  final List<OrderDetailItem> details;

  OrderQueueItem({
    required this.order,
    required this.tableName,
    required this.details,
  });
}
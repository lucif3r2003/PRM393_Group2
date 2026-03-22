class Order {
  final int? orderId;
  final int tableId;
  final int waiterId;
  final double totalAmount;
  final String status; // 'Pending', 'Preparing', 'Ready', 'Completed'
  final DateTime createdAt; // Trong Dart dùng DateTime, SQLite lưu chuỗi ISO8601

  Order({
    this.orderId,
    required this.tableId,
    required this.waiterId,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'OrderID': orderId,
      'TableID': tableId,
      'WaiterID': waiterId,
      'TotalAmount': totalAmount,
      'Status': status,
      'CreatedAt': createdAt.toIso8601String(), // Chuyển DateTime thành chuỗi cho SQLite
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['OrderID'] as int?,
      tableId: map['TableID'] as int,
      waiterId: map['WaiterID'] as int,
      totalAmount: (map['TotalAmount'] as num).toDouble(),
      status: map['Status'] as String,
      createdAt: DateTime.parse(map['CreatedAt'] as String), // Chuyển chuỗi từ SQLite thành DateTime
    );
  }
}
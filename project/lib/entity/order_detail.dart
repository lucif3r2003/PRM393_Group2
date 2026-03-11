class OrderDetail {
  final int? orderDetailId;
  final int orderId;
  final int productId;
  final int quantity;
  final String? note; // Ghi chú thêm, có thể null

  OrderDetail({
    this.orderDetailId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'OrderDetailID': orderDetailId,
      'OrderID': orderId,
      'ProductID': productId,
      'Quantity': quantity,
      'Note': note,
    };
  }

  factory OrderDetail.fromMap(Map<String, dynamic> map) {
    return OrderDetail(
      orderDetailId: map['OrderDetailID'] as int?,
      orderId: map['OrderID'] as int,
      productId: map['ProductID'] as int,
      quantity: map['Quantity'] as int,
      note: map['Note'] as String?,
    );
  }
}
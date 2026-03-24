class CartItem {
  final int productId;
  final String productName;
  final double price;
  int quantity;

  int sugar; // %
  int ice;   // %
  List<String> toppings;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    this.quantity = 1,
    this.sugar = 100,
    this.ice = 100,
    this.toppings = const [],
  });

  String get note {
    return "Đường: $sugar%, Đá: $ice%, Topping: ${toppings.join(", ")}";
  }

  double get total => price * quantity;
}

import 'package:project/entity/cart_item.dart';
class CartProvider {
  static final List<CartItem> _items = [];

  static List<CartItem> get items => _items;

  static void addItem(CartItem item) {
    _items.add(item);
  }

  static double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.total);
  }

  static void clear() {
    _items.clear();
  }
}
  
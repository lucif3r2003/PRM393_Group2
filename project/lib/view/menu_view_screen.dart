import 'package:flutter/material.dart';
import 'package:project/entity/product.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/view/order_screen.dart';

class MenuViewScreen extends StatefulWidget {
  final int tableId;
  final String tableName;
  final int waiterId;
  final String waiterName;

  const MenuViewScreen({
    super.key,
    required this.tableId,
    required this.tableName,
    required this.waiterId,
    required this.waiterName,
  });

  @override
  State<MenuViewScreen> createState() => _MenuViewScreenState();
}

class _MenuViewScreenState extends State<MenuViewScreen> {
  final List<String> categories = ['Tất cả', 'Cà phê', 'Trà', 'Đồ ăn', 'Khác'];
  String searchQueries = "";
  final Map<int, Map<String, dynamic>> _cart = {};

  int get _totalItems {
    var total = 0;
    for (final item in _cart.values) {
      total += item['quantity'] as int;
    }
    return total;
  }

  void _addToCart(Product product) {
    final key = product.productID!;
    final existing = _cart[key];
    if (existing == null) {
      _cart[key] = {
        'productId': product.productID,
        'productName': product.productName,
        'price': product.price,
        'quantity': 1,
        'note': null,
      };
    } else {
      existing['quantity'] = (existing['quantity'] as int) + 1;
    }
    setState(() {});
  }

  void _removeFromCart(Product product) {
    final key = product.productID!;
    final existing = _cart[key];
    if (existing == null) return;

    final nextQty = (existing['quantity'] as int) - 1;
    if (nextQty <= 0) {
      _cart.remove(key);
    } else {
      existing['quantity'] = nextQty;
    }
    setState(() {});
  }

  void _goToOrderScreen() {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa chọn món nào.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderScreen(
          tableId: widget.tableId,
          tableName: widget.tableName,
          waiterId: widget.waiterId,
          waiterName: widget.waiterName,
          items: _cart.values.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Drink Detail - ${widget.tableName}'),
          bottom: TabBar(
            isScrollable: true,
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm tên món...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQueries = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                children: categories.map((cat) {
                  return _buildProductList(category: cat);
                }).toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToOrderScreen,
          icon: const Icon(Icons.receipt_long),
          label: Text('Order ($_totalItems)'),
        ),
      ),
    );
  }

  Widget _buildProductList({required String category}) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: category == 'Tất cả'
          ? DatabaseHelper.instance.getAllProducts()
          : DatabaseHelper.instance.getProductsByCategory(category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final rawProducts = snapshot.data ?? [];
        List<Product> products = rawProducts
            .map((map) => Product.fromMap(map))
            .where((p) => p.productName.toLowerCase().contains(searchQueries))
            .toList();

        if (products.isEmpty) {
          return const Center(child: Text('Không tìm thấy món nào.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.brown.shade100,
                  child: const Icon(Icons.local_cafe, color: Colors.brown),
                ),
                title: Text(
                  product.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(0)} VNĐ',
                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => _removeFromCart(product),
                    ),
                    Text('${_cart[product.productID]?['quantity'] ?? 0}'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                      onPressed: () => _addToCart(product),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
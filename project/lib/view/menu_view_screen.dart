import 'package:flutter/material.dart';
import 'package:project/entity/product.dart';
import 'package:project/repository/database_helper.dart';

class MenuViewScreen extends StatefulWidget {
  const MenuViewScreen({super.key});

  @override
  State<MenuViewScreen> createState() => _MenuViewScreenState();
}

class _MenuViewScreenState extends State<MenuViewScreen> {
  // Danh sách các danh mục món ăn (Có thể lấy động từ DB hoặc fix cứng theo yêu cầu)
  final List<String> categories = ['Tất cả', 'Cà phê', 'Trà', 'Đồ ăn', 'Khác'];
  String searchQueries = "";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: categories.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thực đơn (Menu)'),
          bottom: TabBar(
            isScrollable: true, // Cho phép vuốt ngang các tab nếu quá dài
            tabs: categories.map((cat) => Tab(text: cat)).toList(),
          ),
        ),
        body: Column(
          children: [
            // Thanh tìm kiếm nhanh
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
            // Hiển thị danh sách sản phẩm theo từng Tab
            Expanded(
              child: TabBarView(
                children: categories.map((cat) {
                  return _buildProductList(category: cat);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList({required String category}) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      // Nếu là 'Tất cả' thì gọi getAll, ngược lại gọi theo Category
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

        // Chuyển đổi dữ liệu Map từ SQLite sang List<Product>
        List<Product> products = snapshot.data!
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
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                  onPressed: () {
                    // Logic để thêm vào giỏ hàng (Phần của bạn khác trong nhóm)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã chọn: ${product.productName}')),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
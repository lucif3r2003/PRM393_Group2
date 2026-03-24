import 'package:flutter/material.dart';
import 'package:project/entity/order_queue_item.dart';
import 'package:project/repository/auth_session.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/view/login_screen.dart';

class OrderQueueScreen extends StatefulWidget {
  const OrderQueueScreen({super.key});

  @override
  State<OrderQueueScreen> createState() => _OrderQueueScreenState();
}

//  2. Lớp State quản lý trạng thái của màn hình
class _OrderQueueScreenState extends State<OrderQueueScreen> {
  bool get _canUpdateStatus => AuthSession.hasAnyRole(['Admin', 'Bartender']);

  void _logout(BuildContext context) {
    AuthSession.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 Trạng thái đơn hàng
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hàng đợi pha chế (Order Queue)'),
          actions: [
            IconButton(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Đang chờ'),
              Tab(text: 'Đang pha'),
              Tab(text: 'Đã xong'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(status: 'Pending'),
            _buildOrderList(status: 'Preparing'),
            _buildOrderList(status: 'Ready'),
          ],
        ),
      ),
    );
  }

  // Hàm build danh sách (Đã được đưa vào trong lớp State)
  Widget _buildOrderList({required String status}) {
    return FutureBuilder<List<OrderQueueItem>>(
      future: DatabaseHelper.instance.getOrderQueueByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }
        
        final queueItems = snapshot.data;
        
        if (queueItems == null || queueItems.isEmpty) {
          return const Center(child: Text('Không có đơn hàng nào ở trạng thái này.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: queueItems.length,
          itemBuilder: (context, index) {
            final item = queueItems[index];
            
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.tableName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        // Mẹo nhỏ: dùng padLeft để format phút (VD: 10:05 thay vì 10:5)
                        Text('${item.order.createdAt.hour}:${item.order.createdAt.minute.toString().padLeft(2, '0')}', 
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const Divider(),
                    
                    ...item.details.map((detail) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${detail.quantity} x ${detail.productName}', style: const TextStyle(fontSize: 16)),
                            if (detail.note != null && detail.note!.isNotEmpty)
                              Text('   - Note: ${detail.note}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.orange)),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 16),
                    
                    if (_canUpdateStatus && status != 'Ready') 
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: status == 'Pending' ? Colors.blue : Colors.green,
                          ),
                          onPressed: () async {
                            // 1. Tính toán trạng thái tiếp theo
                            String nextStatus = status == 'Pending' ? 'Preparing' : 'Ready';
                            
                            // 2. Cập nhật xuống SQLite
                            await DatabaseHelper.instance.updateOrderStatus(item.order.orderId!, nextStatus);
                            
                            // 3. GỌI SETSTATE ĐỂ REFRESH MÀN HÌNH NGAY LẬP TỨC
                            setState(() {}); 
                          },
                          child: Text(
                            status == 'Pending' ? 'Bắt đầu pha chế' : 'Hoàn thành (Ready)',
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
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
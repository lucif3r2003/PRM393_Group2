import 'package:flutter/material.dart';
import 'package:project/repository/auth_session.dart';
import 'package:project/repository/database_helper.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // Biến lưu trữ dữ liệu
  Map<String, dynamic> generalReport = {'TotalOrders': 0, 'TotalRevenue': 0.0};
  List<Map<String, dynamic>> productReport = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  // Hàm gọi DB để lấy dữ liệu
  Future<void> _loadReportData() async {
    final general = await DatabaseHelper.instance.getGeneralReport();
    final products = await DatabaseHelper.instance.getProductUsageReport();

    setState(() {
      generalReport = general;
      productReport = products;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthSession.hasAnyRole(['Admin'])) {
      return Scaffold(
        appBar: AppBar(title: const Text('Báo cáo doanh thu (Admin)')),
        body: const Center(
          child: Text('Bạn không có quyền truy cập màn hình này.'),
        ),
      );
    }

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Format tiền tệ cho đẹp
    final totalRevenue = (generalReport['TotalRevenue'] as num?)?.toDouble() ?? 0.0;
    final totalOrders = generalReport['TotalOrders'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo doanh thu (Admin)'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. DASHBOARD TỔNG QUAN ---
            Row(
              children: [
                Expanded(child: _buildStatCard('Tổng Đơn Hàng', '$totalOrders', Icons.receipt_long, Colors.orange)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Doanh Thu (VNĐ)', '${totalRevenue.toStringAsFixed(0)}', Icons.monetization_on, Colors.green)),
              ],
            ),
            const SizedBox(height: 24),

            // --- 2. BÁO CÁO SẢN PHẨM ĐÃ BÁN (Product Used) ---
            const Text(
              'Top Sản Phẩm Bán Chạy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: productReport.isEmpty
                  ? const Center(child: Text('Chưa có dữ liệu bán hàng.'))
                  : ListView.builder(
                itemCount: productReport.length,
                itemBuilder: (context, index) {
                  final item = productReport[index];
                  final revenue = (item['Revenue'] as num).toDouble();

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey.shade100,
                        child: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      ),
                      title: Text(item['ProductName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Đã bán: ${item['TotalSold']} ly'),
                      trailing: Text(
                        '+${revenue.toStringAsFixed(0)} đ',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Nút Refresh để Admin cập nhật dữ liệu mới nhất
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() { isLoading = true; });
          _loadReportData();
        },
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  // Widget vẽ thẻ thống kê (Card)
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:project/repository/auth_session.dart';
import 'package:project/view/login_screen.dart';
import 'package:project/view/order_queue.dart';
import 'package:project/view/product_list_screen.dart';
import 'package:project/view/report_screen.dart';
import 'package:project/view/user_list_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  void _logout(BuildContext context) {
    AuthSession.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthSession.hasAnyRole(['Admin'])) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Home')),
        body: const Center(
          child: Text('Bạn không có quyền truy cập màn hình Admin Home.'),
        ),
      );
    }

    final name = AuthSession.currentUser?.fullName ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào, $name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Chọn chức năng quản trị theo luồng hệ thống.'),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildMenuCard(
                    context: context,
                    title: 'User List',
                    subtitle: 'View/Change Permissions',
                    icon: Icons.group,
                    color: Colors.indigo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserListScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Product List',
                    subtitle: 'Add/Edit/Delete Items',
                    icon: Icons.inventory_2,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProductListScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Report',
                    subtitle: 'Báo cáo doanh thu',
                    icon: Icons.bar_chart,
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportScreen()),
                    ),
                  ),
                  _buildMenuCard(
                    context: context,
                    title: 'Order Status',
                    subtitle: 'Theo dõi pha chế',
                    icon: Icons.local_cafe,
                    color: Colors.brown,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrderQueueScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: color),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

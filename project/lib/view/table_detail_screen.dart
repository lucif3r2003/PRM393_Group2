import 'package:flutter/material.dart';
import 'package:project/entity/table.dart' as entity;
import 'package:project/repository/database_helper.dart';
import 'package:project/view/menu_view_screen.dart';

class TableDetailScreen extends StatefulWidget {
  final entity.Table table;
  final int waiterId;
  final String waiterName;

  const TableDetailScreen({
    super.key,
    required this.table,
    required this.waiterId,
    required this.waiterName,
  });

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.table.status;
  }

  void _updateStatus(String newStatus) async {
    await DatabaseHelper.instance.updateTableStatus(
      widget.table.tableId!,
      newStatus,
    );
    setState(() {
      currentStatus = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã chuyển ${widget.table.tableName} sang $newStatus"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết ${widget.table.tableName}"),
        backgroundColor: Colors.brown[400],
      ),
      body: Column(
        children: [
          // Phần đầu hiển thị trạng thái to rõ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            color: Colors.brown[50],
            child: Column(
              children: [
                const Icon(Icons.info_outline, size: 50, color: Colors.brown),
                const SizedBox(height: 10),
                Text(
                  "Trạng thái: $currentStatus",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: currentStatus == 'Empty' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "Thao tác nhanh",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                _buildActionButton(
                  icon: Icons.local_drink,
                  label: "Drink Detail",
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MenuViewScreen(
                          tableId: widget.table.tableId!,
                          tableName: widget.table.tableName,
                          waiterId: widget.waiterId,
                        ),
                      ),
                    );
                  },
                ),

                _buildActionButton(
                  icon: Icons.payments_outlined,
                  label: "Đánh dấu bàn trống",
                  color: Colors.green,
                  onTap: () => _updateStatus('Empty'),
                ),

                _buildActionButton(
                  icon: Icons.bookmark_outline,
                  label: "Khách đặt trước (Reserved)",
                  color: Colors.orange,
                  onTap: () => _updateStatus('Reserved'),
                ),

                const Divider(height: 40),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Quay lại sơ đồ bàn"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

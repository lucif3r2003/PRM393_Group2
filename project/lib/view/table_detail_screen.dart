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
  int? _activeOrderId;
  List<Map<String, dynamic>> _servingItems = [];
  bool _loadingServing = false;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.table.status;
    _loadServingData();
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

  Future<void> _reloadStatusFromDb() async {
    final latest = await DatabaseHelper.instance.getTableById(widget.table.tableId!);
    if (!mounted || latest == null) return;
    setState(() {
      currentStatus = latest.status;
    });
    await _loadServingData();
  }

  Future<void> _loadServingData() async {
    setState(() {
      _loadingServing = true;
    });
    final activeOrder = await DatabaseHelper.instance.getActiveOrderByTable(
      widget.table.tableId!,
    );
    if (activeOrder == null) {
      if (!mounted) return;
      setState(() {
        _activeOrderId = null;
        _servingItems = [];
        _loadingServing = false;
      });
      return;
    }

    final orderId = activeOrder['OrderID'] as int;
    final items = await DatabaseHelper.instance.getOrderItems(orderId);
    if (!mounted) return;
    setState(() {
      _activeOrderId = orderId;
      _servingItems = items;
      _loadingServing = false;
    });
  }

  Future<void> _confirmPayment() async {
    if (_activeOrderId == null) return;
    await DatabaseHelper.instance.completePayment(_activeOrderId!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanh toán thành công, bàn đã về Empty')),
    );
    await _reloadStatusFromDb();
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MenuViewScreen(
                          tableId: widget.table.tableId!,
                          tableName: widget.table.tableName,
                          waiterId: widget.waiterId,
                          waiterName: widget.waiterName,
                        ),
                      ),
                    );
                    await _reloadStatusFromDb();
                  },
                ),

                _buildActionButton(
                  icon: Icons.bookmark_outline,
                  label: "Khách đặt trước (Reserved)",
                  color: Colors.orange,
                  onTap: () => _updateStatus('Reserved'),
                ),

                if (currentStatus == 'Occupied') ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Danh sách món đang phục vụ',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (_loadingServing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_servingItems.isEmpty)
                    const Card(
                      child: ListTile(
                        title: Text('Chưa có món đang phục vụ cho bàn này.'),
                      ),
                    )
                  else
                    ..._servingItems.map(
                      (item) {
                        final quantity = item['Quantity'] as int;
                        final price = (item['Price'] as num).toDouble();
                        return Card(
                          child: ListTile(
                            title: Text(item['ProductName'] as String),
                            subtitle: Text('Số lượng: $quantity'),
                            trailing: Text(
                              '${(quantity * price).toStringAsFixed(0)} đ',
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _servingItems.isEmpty ? null : _confirmPayment,
                      icon: const Icon(Icons.payments),
                      label: const Text('Thanh toán'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],

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

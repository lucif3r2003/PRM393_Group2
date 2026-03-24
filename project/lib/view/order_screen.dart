import 'package:flutter/material.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/view/checkout_screen.dart';

class OrderScreen extends StatefulWidget {
  final int tableId;
  final String tableName;
  final int waiterId;
  final List<Map<String, dynamic>> items;

  const OrderScreen({
    super.key,
    required this.tableId,
    required this.tableName,
    required this.waiterId,
    required this.items,
  });

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isSubmitting = false;

  double get _total {
    var total = 0.0;
    for (final item in widget.items) {
      final price = (item['price'] as num).toDouble();
      final quantity = item['quantity'] as int;
      total += price * quantity;
    }
    return total;
  }

  Future<void> _confirmOrder() async {
    setState(() => _isSubmitting = true);
    try {
      final orderId = await DatabaseHelper.instance.createOrder(
        tableId: widget.tableId,
        waiterId: widget.waiterId,
        items: widget.items,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CheckoutScreen(
            orderId: orderId,
            tableName: widget.tableName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tạo order: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order - ${widget.tableName}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final qty = item['quantity'] as int;
                final price = (item['price'] as num).toDouble();
                return Card(
                  child: ListTile(
                    title: Text(item['productName'] as String),
                    subtitle: Text('$qty x ${price.toStringAsFixed(0)} đ'),
                    trailing: Text(
                      '${(qty * price).toStringAsFixed(0)} đ',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng: ${_total.toStringAsFixed(0)} đ',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _confirmOrder,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Xác nhận Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

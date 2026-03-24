import 'package:flutter/material.dart';
import 'package:project/repository/auth_session.dart';
import 'package:project/repository/database_helper.dart';
import 'package:project/view/beverage_status_screen.dart';
import 'package:project/view/payment_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int orderId;
  final String tableName;

  const CheckoutScreen({
    super.key,
    required this.orderId,
    required this.tableName,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;
  late Future<Map<String, dynamic>?> _orderFuture;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _itemsFuture = DatabaseHelper.instance.getOrderItems(widget.orderId);
    _orderFuture = DatabaseHelper.instance.getOrderById(widget.orderId);
  }

  Future<void> _confirmPayment() async {
    setState(() => _paying = true);
    try {
      await DatabaseHelper.instance.completePayment(widget.orderId);
      if (!mounted) return;

      final waiterId = AuthSession.currentUser?.userId;
      final waiterName = AuthSession.currentUser?.fullName;
      if (waiterId == null || waiterName == null) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentConfirmationScreen(
            waiterId: waiterId,
            waiterName: waiterName,
            tableName: widget.tableName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán thất bại: $e')),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Out - ${widget.tableName}'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: _orderFuture,
              builder: (context, snapshot) {
                final order = snapshot.data;
                final total = (order?['TotalAmount'] as num?)?.toDouble() ?? 0.0;
                final status = order?['Status'] as String? ?? 'Unknown';
                return Card(
                  child: ListTile(
                    title: Text('Order #${widget.orderId}'),
                    subtitle: Text('Trạng thái: $status'),
                    trailing: Text(
                      '${total.toStringAsFixed(0)} đ',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Chi tiết đơn hàng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Center(child: Text('Không có món trong order.'));
                  }
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final quantity = item['Quantity'] as int;
                      final price = (item['Price'] as num).toDouble();
                      return Card(
                        child: ListTile(
                          title: Text(item['ProductName'] as String),
                          subtitle: Text('Số lượng: $quantity'),
                          trailing: Text('${(quantity * price).toStringAsFixed(0)} đ'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BeverageStatusScreen(orderId: widget.orderId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.local_drink),
                    label: const Text('View Beverage Status'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _paying ? null : _confirmPayment,
                    icon: _paying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.payments),
                    label: const Text('Payment Confirmation'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

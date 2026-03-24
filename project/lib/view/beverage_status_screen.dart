import 'package:flutter/material.dart';
import 'package:project/repository/database_helper.dart';

class BeverageStatusScreen extends StatefulWidget {
  final int orderId;

  const BeverageStatusScreen({super.key, required this.orderId});

  @override
  State<BeverageStatusScreen> createState() => _BeverageStatusScreenState();
}

class _BeverageStatusScreenState extends State<BeverageStatusScreen> {
  late Future<String> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = DatabaseHelper.instance.getOrderStatus(widget.orderId);
  }

  void _refresh() {
    setState(() {
      _statusFuture = DatabaseHelper.instance.getOrderStatus(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Beverage Status'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: _statusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final status = snapshot.data ?? 'Unknown';
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${widget.orderId}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trạng thái hiện tại: $status',
                  style: TextStyle(
                    fontSize: 17,
                    color: _statusColor(status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tiến trình đồ uống:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _stepTile('Pending', status),
                _stepTile('Preparing', status),
                _stepTile('Ready', status),
                _stepTile('Paid', status),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới trạng thái'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _stepTile(String step, String currentStatus) {
    const order = ['Pending', 'Preparing', 'Ready', 'Paid'];
    final currentIndex = order.indexOf(currentStatus);
    final stepIndex = order.indexOf(step);
    final done = currentIndex >= stepIndex && currentIndex >= 0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        done ? Icons.check_circle : Icons.radio_button_unchecked,
        color: done ? Colors.green : Colors.grey,
      ),
      title: Text(step),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Ready':
        return Colors.green;
      case 'Paid':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:project/view/list_table_screen.dart';

class PaymentConfirmationScreen extends StatelessWidget {
  final int waiterId;
  final String waiterName;
  final String tableName;

  const PaymentConfirmationScreen({
    super.key,
    required this.waiterId,
    required this.waiterName,
    required this.tableName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Confirmation'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 90, color: Colors.green),
              const SizedBox(height: 14),
              Text(
                '$tableName đã thanh toán thành công',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => TableListScreen(
                          waiterId: waiterId,
                          waiterName: waiterName,
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Text('Quay về danh sách bàn'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

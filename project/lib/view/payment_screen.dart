import 'package:flutter/material.dart';
import 'package:project/provider/cart_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String bill = CartProvider.items.map((e) =>
      "${e.productName} (${e.note})"
    ).join("\n");

    return Scaffold(
      appBar: AppBar(title: const Text("Thanh toán")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(bill),

          Text("Tổng: ${CartProvider.totalAmount} VNĐ"),

          const SizedBox(height: 20),

          QrImageView(
            data: bill,
            size: 200,
          ),
        ],
      ),
    );
  }
}

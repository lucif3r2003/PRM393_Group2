import 'package:flutter/material.dart';
import 'package:project/provider/cart_provider.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: CartProvider.items.length,
              itemBuilder: (context, index) {
                final item = CartProvider.items[index];

                return ListTile(
                  title: Text(item.productName),
                  subtitle: Text(item.note),
                  trailing: Text("${item.total}"),
                );
              },
            ),
          ),

          Text("Tổng: ${CartProvider.totalAmount} VNĐ"),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/payment');
            },
            child: const Text("Thanh toán"),
          )
        ],
      ),
    );
  }
}

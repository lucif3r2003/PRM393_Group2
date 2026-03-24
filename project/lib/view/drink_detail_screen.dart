import 'package:flutter/material.dart';
import 'package:project/entity/product.dart';
import 'package:project/entity/cart_item.dart';
import 'package:project/provider/cart_provider.dart';

class DrinkDetailScreen extends StatefulWidget {
  final Product product;

  const DrinkDetailScreen({super.key, required this.product});

  @override
  State<DrinkDetailScreen> createState() => _DrinkDetailScreenState();
}

class _DrinkDetailScreenState extends State<DrinkDetailScreen> {
  int sugar = 100;
  int ice = 100;
  List<String> toppings = [];

  final List<String> toppingList = ['Trân châu', 'Thạch', 'Kem cheese'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product.productName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            _buildSlider("Đường", sugar, (v) => setState(() => sugar = v)),
            _buildSlider("Đá", ice, (v) => setState(() => ice = v)),

            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Topping", style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            ...toppingList.map((t) => CheckboxListTile(
              title: Text(t),
              value: toppings.contains(t),
              onChanged: (val) {
                setState(() {
                  val! ? toppings.add(t) : toppings.remove(t);
                });
              },
            )),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                CartProvider.addItem(
                  CartItem(
                    productId: widget.product.productID!,
                    productName: widget.product.productName,
                    price: widget.product.price,
                    sugar: sugar,
                    ice: ice,
                    toppings: toppings,
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Thêm vào đơn"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String title, int value, Function(int) onChanged) {
    return Column(
      children: [
        Text("$title: $value%"),
        Slider(
          value: value.toDouble(),
          min: 0,
          max: 100,
          divisions: 4,
          onChanged: (v) => onChanged(v.toInt()),
        )
      ],
    );
  }
}

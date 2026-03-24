class Product
{
  final int? productID;
  final String productName;
  final String category;
  final double price;
  final String description;

  Product({
    this.productID,
    required this.productName,
    required this.category,
    required this.price,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'ProductID': productID,
      'ProductName': productName,
      'Category': category,
      'Price': price,
      'Description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      productID: map['ProductID'] as int?,
      productName: map['ProductName'] as String,
      category: map['Category'] as String,
      price: (map['Price'] as num).toDouble(),
      description: map['Description'] as String,
    );
  }
}
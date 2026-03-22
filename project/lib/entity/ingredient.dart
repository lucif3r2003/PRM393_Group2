class Ingredient {
  final int? ingredientID;
  final String ingredientName;
  final int stockQuantity;
  final String unit;

  Ingredient({
    this.ingredientID,
    required this.ingredientName,
    required this.stockQuantity,
    required this.unit
  });

  Map<String, dynamic> toMap() {
    return {
      'IngredientID': ingredientID,
      'IngredientName': ingredientName,
      'StockQuantity': stockQuantity,
      'Unit': unit,
    };
  }

  factory Ingredient.fromMap(Map<String, dynamic> map) {
    return Ingredient(
      ingredientID: map['IngredientID'] as int?,
      ingredientName: map['IngredientName'] as String,
      stockQuantity: (map['StockQuantity'] as num).toInt(),
      unit: map['Unit'] as String,
    );
  }
}
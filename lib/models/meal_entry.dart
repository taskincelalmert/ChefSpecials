import 'package:uuid/uuid.dart';

enum MealType { breakfast, lunch, dinner, snack }

class MealEntry {
  final String id;
  final String name;
  final MealType mealType;
  final String? foodItemId;
  final String? recipeId;
  final double quantity; // grams or mL
  final String unit; // "g" or "mL"
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MealEntry({
    String? id,
    required this.name,
    required this.mealType,
    this.foodItemId,
    this.recipeId,
    required this.quantity,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  }) : id = id ?? const Uuid().v4();

  factory MealEntry.fromMap(Map<String, dynamic> map) {
    return MealEntry(
      id: map['id'] as String?,
      name: map['name'] as String,
      mealType: MealType.values.firstWhere(
        (e) => e.name == map['mealType'],
        orElse: () => MealType.snack,
      ),
      foodItemId: map['foodItemId'] as String?,
      recipeId: map['recipeId'] as String?,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String? ?? 'g',
      calories: (map['calories'] as num).toDouble(),
      protein: (map['protein'] as num).toDouble(),
      carbs: (map['carbs'] as num).toDouble(),
      fat: (map['fat'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType.name,
      'foodItemId': foodItemId,
      'recipeId': recipeId,
      'quantity': quantity,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

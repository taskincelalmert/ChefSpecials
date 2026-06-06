import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/meal_entry.dart';

void main() {
  group('MealType', () {
    test('has exactly 4 values', () {
      expect(MealType.values.length, 4);
    });

    test('contains breakfast, lunch, dinner, snack', () {
      expect(MealType.values, contains(MealType.breakfast));
      expect(MealType.values, contains(MealType.lunch));
      expect(MealType.values, contains(MealType.dinner));
      expect(MealType.values, contains(MealType.snack));
    });

    test('name property returns correct strings', () {
      expect(MealType.breakfast.name, 'breakfast');
      expect(MealType.lunch.name, 'lunch');
      expect(MealType.dinner.name, 'dinner');
      expect(MealType.snack.name, 'snack');
    });
  });

  group('MealEntry', () {
    group('fromMap', () {
      test('creates MealEntry with all fields', () {
        final map = {
          'name': 'Grilled Chicken',
          'mealType': 'lunch',
          'foodItemId': 'food123',
          'recipeId': 'recipe456',
          'quantity': 200.0,
          'unit': 'g',
          'calories': 330.0,
          'protein': 62.0,
          'carbs': 0.0,
          'fat': 7.2,
        };

        final entry = MealEntry.fromMap(map);

        expect(entry.name, 'Grilled Chicken');
        expect(entry.mealType, MealType.lunch);
        expect(entry.foodItemId, 'food123');
        expect(entry.recipeId, 'recipe456');
        expect(entry.quantity, 200.0);
        expect(entry.unit, 'g');
        expect(entry.calories, 330.0);
        expect(entry.protein, 62.0);
        expect(entry.carbs, 0.0);
        expect(entry.fat, 7.2);
      });

      test('creates MealEntry with nullable fields as null', () {
        final map = {
          'name': 'Apple',
          'mealType': 'snack',
          'quantity': 150,
          'unit': 'g',
          'calories': 78,
          'protein': 0.4,
          'carbs': 20.6,
          'fat': 0.2,
        };

        final entry = MealEntry.fromMap(map);

        expect(entry.foodItemId, isNull);
        expect(entry.recipeId, isNull);
      });

      test('defaults unit to g when missing', () {
        final map = {
          'name': 'Rice',
          'mealType': 'dinner',
          'quantity': 300,
          'calories': 390,
          'protein': 8.1,
          'carbs': 86.1,
          'fat': 0.9,
        };

        final entry = MealEntry.fromMap(map);

        expect(entry.unit, 'g');
      });

      test('defaults to MealType.snack for unknown mealType', () {
        final map = {
          'name': 'Mystery food',
          'mealType': 'brunch',
          'quantity': 100,
          'unit': 'g',
          'calories': 100,
          'protein': 5,
          'carbs': 10,
          'fat': 3,
        };

        final entry = MealEntry.fromMap(map);

        expect(entry.mealType, MealType.snack);
      });

      test('converts int values to double for numeric fields', () {
        final map = {
          'name': 'Bread',
          'mealType': 'breakfast',
          'quantity': 50,
          'unit': 'g',
          'calories': 132,
          'protein': 4,
          'carbs': 25,
          'fat': 2,
        };

        final entry = MealEntry.fromMap(map);

        expect(entry.quantity, isA<double>());
        expect(entry.calories, isA<double>());
        expect(entry.protein, isA<double>());
        expect(entry.carbs, isA<double>());
        expect(entry.fat, isA<double>());
        expect(entry.quantity, 50.0);
        expect(entry.calories, 132.0);
      });

      test('parses all MealType enum values', () {
        for (final type in MealType.values) {
          final map = {
            'name': 'Test',
            'mealType': type.name,
            'quantity': 100,
            'unit': 'g',
            'calories': 100,
            'protein': 10,
            'carbs': 10,
            'fat': 5,
          };

          final entry = MealEntry.fromMap(map);
          expect(entry.mealType, type);
        }
      });
    });

    group('toMap', () {
      test('serializes all fields correctly', () {
        final entry = MealEntry(
          name: 'Oatmeal',
          mealType: MealType.breakfast,
          foodItemId: 'oat1',
          recipeId: 'recipe1',
          quantity: 250.0,
          unit: 'g',
          calories: 380.0,
          protein: 13.0,
          carbs: 67.0,
          fat: 6.5,
        );

        final map = entry.toMap();

        expect(map['name'], 'Oatmeal');
        expect(map['mealType'], 'breakfast');
        expect(map['foodItemId'], 'oat1');
        expect(map['recipeId'], 'recipe1');
        expect(map['quantity'], 250.0);
        expect(map['unit'], 'g');
        expect(map['calories'], 380.0);
        expect(map['protein'], 13.0);
        expect(map['carbs'], 67.0);
        expect(map['fat'], 6.5);
      });

      test('serializes mealType as string name', () {
        final entry = MealEntry(
          name: 'Salad',
          mealType: MealType.dinner,
          quantity: 300.0,
          unit: 'g',
          calories: 100.0,
          protein: 3.0,
          carbs: 12.0,
          fat: 5.0,
        );

        final map = entry.toMap();
        expect(map['mealType'], 'dinner');
      });

      test('includes null foodItemId and recipeId', () {
        final entry = MealEntry(
          name: 'Coffee',
          mealType: MealType.breakfast,
          quantity: 200.0,
          unit: 'mL',
          calories: 2.0,
          protein: 0.3,
          carbs: 0.0,
          fat: 0.0,
        );

        final map = entry.toMap();
        expect(map.containsKey('foodItemId'), isTrue);
        expect(map['foodItemId'], isNull);
        expect(map.containsKey('recipeId'), isTrue);
        expect(map['recipeId'], isNull);
      });
    });

    group('fromMap/toMap round-trip', () {
      test('round-trip preserves all fields', () {
        final originalMap = {
          'id': 'meal001',
          'name': 'Pasta',
          'mealType': 'lunch',
          'foodItemId': 'pasta001',
          'recipeId': 'recipe001',
          'quantity': 350.0,
          'unit': 'g',
          'calories': 525.0,
          'protein': 18.0,
          'carbs': 75.0,
          'fat': 15.0,
        };

        final entry = MealEntry.fromMap(originalMap);
        final resultMap = entry.toMap();

        expect(resultMap, originalMap);
      });

      test('round-trip preserves null optional fields', () {
        final originalMap = {
          'id': 'meal002',
          'name': 'Water',
          'mealType': 'snack',
          'foodItemId': null,
          'recipeId': null,
          'quantity': 500.0,
          'unit': 'mL',
          'calories': 0.0,
          'protein': 0.0,
          'carbs': 0.0,
          'fat': 0.0,
        };

        final entry = MealEntry.fromMap(originalMap);
        final resultMap = entry.toMap();

        expect(resultMap, originalMap);
      });
    });

    group('edge cases', () {
      test('handles zero quantity', () {
        final entry = MealEntry(
          name: 'Nothing',
          mealType: MealType.snack,
          quantity: 0.0,
          unit: 'g',
          calories: 0.0,
          protein: 0.0,
          carbs: 0.0,
          fat: 0.0,
        );

        expect(entry.quantity, 0.0);
        expect(entry.calories, 0.0);
      });

      test('handles mL unit', () {
        final entry = MealEntry(
          name: 'Milk',
          mealType: MealType.breakfast,
          quantity: 200.0,
          unit: 'mL',
          calories: 122.0,
          protein: 6.6,
          carbs: 9.6,
          fat: 6.6,
        );

        expect(entry.unit, 'mL');
      });

      test('handles empty name', () {
        final entry = MealEntry(
          name: '',
          mealType: MealType.lunch,
          quantity: 100.0,
          unit: 'g',
          calories: 50.0,
          protein: 5.0,
          carbs: 5.0,
          fat: 1.0,
        );

        expect(entry.name, '');
      });
    });
  });
}

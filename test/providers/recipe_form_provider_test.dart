import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:chef_specials/providers/recipe_form_provider.dart';
import 'package:chef_specials/services/storage_service.dart';
import 'package:chef_specials/models/food_item.dart';
import 'package:chef_specials/models/recipe.dart';
import 'package:chef_specials/models/recipe_step.dart';
import 'package:chef_specials/models/ingredient.dart';

class MockStorageService extends Mock implements StorageService {}

FoodItem _makeFoodItem({
  String name = 'Apple',
  String unit = '100g',
  double calories = 52,
  double protein = 0.3,
  double carbs = 14,
  double fat = 0.2,
}) {
  return FoodItem(
    id: 'food1',
    name: name,
    category: 'Fruits',
    unit: unit,
    packetSize: 100,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    fiber: 2.4,
    sugar: 10.4,
    sodium: 1,
    addedBy: 'user1',
    createdAt: DateTime.now(),
  );
}

void main() {
  late RecipeFormProvider provider;

  setUp(() {
    provider = RecipeFormProvider(storageService: MockStorageService());
  });

  group('RecipeFormProvider', () {
    test('initial state has defaults', () {
      expect(provider.title, '');
      expect(provider.description, '');
      expect(provider.category, 'Breakfast');
      expect(provider.servings, 1);
      expect(provider.prepTimeMinutes, 10);
      expect(provider.cookTimeMinutes, 0);
      expect(provider.imageFile, isNull);
      expect(provider.existingImageUrl, isNull);
      expect(provider.ingredients, isEmpty);
      expect(provider.steps, hasLength(1));
      expect(provider.steps.first.order, 1);
      expect(provider.caloriesPerServing, isNull);
      expect(provider.proteinGrams, isNull);
      expect(provider.carbsGrams, isNull);
      expect(provider.fatGrams, isNull);
      expect(provider.isPrivate, false);
      expect(provider.dietaryTags, isEmpty);
      expect(provider.isSubmitting, false);
    });

    // Ingredient management
    test('addIngredientFromFoodItem adds ingredient with correct unit (100g)',
        () {
      final foodItem = _makeFoodItem(unit: '100g');

      provider.addIngredientFromFoodItem(foodItem, '200');

      expect(provider.ingredients, hasLength(1));
      expect(provider.ingredients.first.name, 'Apple');
      expect(provider.ingredients.first.amount, '200');
      expect(provider.ingredients.first.unit, 'g');
      expect(provider.ingredients.first.foodItemId, 'food1');
    });

    test('addIngredientFromFoodItem uses mL for non-100g unit', () {
      final foodItem = _makeFoodItem(unit: 'mL');

      provider.addIngredientFromFoodItem(foodItem, '250');

      expect(provider.ingredients.first.unit, 'mL');
    });

    test('addIngredientFromFoodItem recalculates nutrition', () {
      final foodItem = _makeFoodItem(
        calories: 100,
        protein: 10,
        carbs: 20,
        fat: 5,
      );

      provider.addIngredientFromFoodItem(foodItem, '200');

      // 200g of 100cal/100g = 200 cal total, 1 serving = 200 per serving
      expect(provider.caloriesPerServing, 200);
      expect(provider.proteinGrams, 20.0);
      expect(provider.carbsGrams, 40.0);
      expect(provider.fatGrams, 10.0);
    });

    test('addIngredientFromFoodItem with multiple ingredients sums nutrition',
        () {
      final apple = _makeFoodItem(
          name: 'Apple', calories: 52, protein: 0.3, carbs: 14, fat: 0.2);
      final chicken = _makeFoodItem(
          name: 'Chicken', calories: 165, protein: 31, carbs: 0, fat: 3.6);

      provider.addIngredientFromFoodItem(apple, '100'); // 52 cal
      provider.addIngredientFromFoodItem(chicken, '100'); // 165 cal

      // Total: 217 cal / 1 serving = 217
      expect(provider.caloriesPerServing, 217);
    });

    test('addIngredientFromFoodItem divides by servings', () {
      provider.servings = 2;

      final foodItem = _makeFoodItem(calories: 100, protein: 10, carbs: 20, fat: 5);
      provider.addIngredientFromFoodItem(foodItem, '200');

      // 200g = 200 cal total / 2 servings = 100 per serving
      expect(provider.caloriesPerServing, 100);
      expect(provider.proteinGrams, 10.0);
      expect(provider.carbsGrams, 20.0);
      expect(provider.fatGrams, 5.0);
    });

    test('addIngredientFromFoodItem notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.addIngredientFromFoodItem(_makeFoodItem(), '100');
      expect(notifyCount, 1);
    });

    test('updateIngredientAmount updates amount and recalculates', () {
      final foodItem = _makeFoodItem(calories: 100);
      provider.addIngredientFromFoodItem(foodItem, '100');
      expect(provider.caloriesPerServing, 100);

      provider.updateIngredientAmount(0, '200');
      expect(provider.ingredients[0].amount, '200');
      expect(provider.caloriesPerServing, 200);
    });

    test('updateIngredientAmount preserves other ingredient properties', () {
      final foodItem = _makeFoodItem();
      provider.addIngredientFromFoodItem(foodItem, '100');

      provider.updateIngredientAmount(0, '500');

      expect(provider.ingredients[0].name, 'Apple');
      expect(provider.ingredients[0].unit, 'g');
      expect(provider.ingredients[0].foodItemId, 'food1');
    });

    test('updateIngredientAmount notifies listeners', () {
      provider.addIngredientFromFoodItem(_makeFoodItem(), '100');

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.updateIngredientAmount(0, '200');
      expect(notifyCount, 1);
    });

    test('removeIngredient removes at index', () {
      provider.addIngredientFromFoodItem(
          _makeFoodItem(name: 'A'), '100');
      provider.addIngredientFromFoodItem(
          _makeFoodItem(name: 'B'), '100');

      provider.removeIngredient(0);

      expect(provider.ingredients, hasLength(1));
      expect(provider.ingredients.first.name, 'B');
    });

    test('removeIngredient recalculates nutrition', () {
      provider.addIngredientFromFoodItem(
          _makeFoodItem(calories: 100), '100');
      provider.addIngredientFromFoodItem(
          _makeFoodItem(calories: 200), '100');
      expect(provider.caloriesPerServing, 300);

      provider.removeIngredient(0);
      expect(provider.caloriesPerServing, 200);
    });

    test('removeIngredient notifies listeners', () {
      provider.addIngredientFromFoodItem(_makeFoodItem(), '100');

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.removeIngredient(0);
      expect(notifyCount, 1);
    });

    test('nutrition is zero when no ingredients', () {
      provider.addIngredientFromFoodItem(_makeFoodItem(), '100');
      provider.removeIngredient(0);

      expect(provider.caloriesPerServing, 0);
      expect(provider.proteinGrams, 0.0);
      expect(provider.carbsGrams, 0.0);
      expect(provider.fatGrams, 0.0);
    });

    test('nutrition handles non-numeric amount gracefully', () {
      final foodItem = _makeFoodItem(calories: 100);
      provider.addIngredientFromFoodItem(foodItem, 'abc');

      // double.tryParse('abc') returns null -> 0 grams
      expect(provider.caloriesPerServing, 0);
    });

    // Step management
    test('addStep adds a new step with correct order', () {
      expect(provider.steps, hasLength(1));

      provider.addStep();
      expect(provider.steps, hasLength(2));
      expect(provider.steps[1].order, 2);
    });

    test('addStep notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.addStep();
      expect(notifyCount, 1);
    });

    test('removeStep removes step and re-orders', () {
      provider.addStep();
      provider.addStep();
      expect(provider.steps, hasLength(3));

      provider.removeStep(1);
      expect(provider.steps, hasLength(2));
      expect(provider.steps[0].order, 1);
      expect(provider.steps[1].order, 2);
    });

    test('removeStep does not remove last step', () {
      expect(provider.steps, hasLength(1));

      provider.removeStep(0);
      expect(provider.steps, hasLength(1));
    });

    test('removeStep notifies listeners', () {
      provider.addStep();

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.removeStep(0);
      expect(notifyCount, 1);
    });

    test('updateStep updates instruction', () {
      provider.updateStep(0, instruction: 'Mix the batter');
      expect(provider.steps[0].instruction, 'Mix the batter');
    });

    test('updateStep updates timerSeconds', () {
      provider.updateStep(0, timerSeconds: 300);
      expect(provider.steps[0].timerSeconds, 300);
    });

    test('updateStep notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.updateStep(0, instruction: 'New instruction');
      expect(notifyCount, 1);
    });

    // Privacy and dietary tags
    test('setIsPrivate changes isPrivate', () {
      provider.setIsPrivate(true);
      expect(provider.isPrivate, true);

      provider.setIsPrivate(false);
      expect(provider.isPrivate, false);
    });

    test('setIsPrivate notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setIsPrivate(true);
      expect(notifyCount, 1);
    });

    test('toggleDietaryTag adds tag', () {
      provider.toggleDietaryTag('vegan');
      expect(provider.dietaryTags, contains('vegan'));
    });

    test('toggleDietaryTag removes existing tag', () {
      provider.toggleDietaryTag('vegan');
      provider.toggleDietaryTag('vegan');
      expect(provider.dietaryTags, isNot(contains('vegan')));
    });

    test('toggleDietaryTag handles multiple tags', () {
      provider.toggleDietaryTag('vegan');
      provider.toggleDietaryTag('gluten-free');
      provider.toggleDietaryTag('low-carb');

      expect(provider.dietaryTags, hasLength(3));
      expect(provider.dietaryTags, containsAll(['vegan', 'gluten-free', 'low-carb']));
    });

    test('toggleDietaryTag notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.toggleDietaryTag('vegan');
      expect(notifyCount, 1);
    });

    // loadFromRecipe
    test('loadFromRecipe populates all fields from recipe', () {
      final recipe = Recipe(
        id: 'r1',
        title: 'Loaded Recipe',
        description: 'Loaded description',
        authorId: 'user1',
        authorName: 'Chef',
        category: 'Dinner',
        servings: 4,
        prepTimeMinutes: 30,
        cookTimeMinutes: 45,
        imageUrl: 'https://example.com/image.jpg',
        ingredients: [
          Ingredient(name: 'Salt', amount: '5', unit: 'g'),
        ],
        steps: [
          RecipeStep(order: 1, instruction: 'Step 1'),
          RecipeStep(order: 2, instruction: 'Step 2'),
        ],
        caloriesPerServing: 350,
        proteinGrams: 25.0,
        carbsGrams: 40.0,
        fatGrams: 10.0,
        createdAt: DateTime.now(),
        isPrivate: true,
        dietaryTags: ['vegan'],
      );

      provider.loadFromRecipe(recipe);

      expect(provider.title, 'Loaded Recipe');
      expect(provider.description, 'Loaded description');
      expect(provider.category, 'Dinner');
      expect(provider.servings, 4);
      expect(provider.prepTimeMinutes, 30);
      expect(provider.cookTimeMinutes, 45);
      expect(provider.existingImageUrl, 'https://example.com/image.jpg');
      expect(provider.ingredients, hasLength(1));
      expect(provider.ingredients.first.name, 'Salt');
      expect(provider.steps, hasLength(2));
      expect(provider.caloriesPerServing, 350);
      expect(provider.proteinGrams, 25.0);
      expect(provider.carbsGrams, 40.0);
      expect(provider.fatGrams, 10.0);
      expect(provider.isPrivate, true);
      expect(provider.dietaryTags, ['vegan']);
    });

    test('loadFromRecipe with empty steps adds default step', () {
      final recipe = Recipe(
        title: 'No Steps',
        description: 'Desc',
        authorId: 'u1',
        authorName: 'Chef',
        category: 'Lunch',
        servings: 1,
        prepTimeMinutes: 5,
        cookTimeMinutes: 0,
        ingredients: [],
        steps: [],
        createdAt: DateTime.now(),
      );

      provider.loadFromRecipe(recipe);

      expect(provider.steps, hasLength(1));
      expect(provider.steps.first.order, 1);
    });

    test('loadFromRecipe notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      final recipe = Recipe(
        title: 'R',
        description: 'D',
        authorId: 'u1',
        authorName: 'C',
        category: 'Breakfast',
        servings: 1,
        prepTimeMinutes: 5,
        cookTimeMinutes: 0,
        ingredients: [],
        steps: [],
        createdAt: DateTime.now(),
      );

      provider.loadFromRecipe(recipe);
      expect(notifyCount, 1);
    });

    // Reset
    test('reset restores all defaults', () {
      // Modify state
      provider.title = 'Modified';
      provider.description = 'Modified desc';
      provider.category = 'Dinner';
      provider.servings = 4;
      provider.isPrivate = true;
      provider.addIngredientFromFoodItem(_makeFoodItem(), '100');
      provider.addStep();
      provider.toggleDietaryTag('vegan');

      provider.reset();

      expect(provider.title, '');
      expect(provider.description, '');
      expect(provider.category, 'Breakfast');
      expect(provider.servings, 1);
      expect(provider.prepTimeMinutes, 10);
      expect(provider.cookTimeMinutes, 0);
      expect(provider.imageFile, isNull);
      expect(provider.existingImageUrl, isNull);
      expect(provider.ingredients, isEmpty);
      expect(provider.steps, hasLength(1));
      expect(provider.caloriesPerServing, isNull);
      expect(provider.proteinGrams, isNull);
      expect(provider.carbsGrams, isNull);
      expect(provider.fatGrams, isNull);
      expect(provider.isPrivate, false);
      expect(provider.dietaryTags, isEmpty);
      expect(provider.isSubmitting, false);
    });

    test('reset notifies listeners', () {
      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.reset();
      expect(notifyCount, 1);
    });

  });
}

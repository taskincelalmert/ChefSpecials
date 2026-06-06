import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/daily_tracker_provider.dart';
import 'package:chef_specials/services/daily_tracker_service.dart';
import 'package:chef_specials/models/meal_entry.dart';
import 'package:chef_specials/models/nutrition_goal.dart';
import '../helpers/mock_firebase_auth.dart';

MealEntry _makeMealEntry({
  String name = 'Apple',
  MealType mealType = MealType.breakfast,
  double calories = 100,
  double protein = 2,
  double carbs = 20,
  double fat = 0.5,
}) {
  return MealEntry(
    name: name,
    mealType: mealType,
    quantity: 100,
    unit: 'g',
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
  );
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DailyTrackerService service;
  late DailyTrackerProvider provider;

  const userId = 'user1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = DailyTrackerService(firestore: fakeFirestore);
    // Inject a signed-out fake auth so the provider never touches the real
    // FirebaseAuth singleton; tests drive the user via provider.init(userId).
    provider = DailyTrackerProvider(
      dailyTrackerService: service,
      firebaseAuth: FakeFirebaseAuth(),
    );
  });

  tearDown(() => provider.dispose());

  group('DailyTrackerProvider', () {
    test('initial state', () {
      expect(provider.dailyLog, isNull);
      expect(provider.nutritionGoal, isNull);
      expect(provider.isLoading, false);
      expect(provider.totalCalories, 0);
      expect(provider.totalProtein, 0);
      expect(provider.totalCarbs, 0);
      expect(provider.totalFat, 0);
    });

    test('init starts listening to log and goal', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog, isNull); // No log yet
      expect(provider.nutritionGoal, isNull); // No goal yet
    });

    test('init does not re-subscribe for same user', () async {
      provider.init(userId);
      provider.init(userId); // should be no-op
      await Future.delayed(Duration.zero);
    });

    test('setDate changes selected date and re-listens', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      final newDate = DateTime(2025, 1, 15);
      provider.setDate(newDate);

      expect(provider.selectedDate, DateTime(2025, 1, 15));
    });

    test('setDate notifies listeners', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      provider.setDate(DateTime(2025, 6, 1));
      expect(notifyCount, 1);
    });

    test('addMealEntry creates a new daily log when none exists', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(name: 'Banana'));
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog, isNotNull);
      expect(provider.dailyLog!.meals, hasLength(1));
      expect(provider.dailyLog!.meals.first.name, 'Banana');
    });

    test('addMealEntry appends to existing daily log', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(name: 'Apple'));
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(name: 'Banana'));
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog!.meals, hasLength(2));
    });

    test('addMealEntry does nothing when userId is null', () async {
      // Don't call init
      await provider.addMealEntry(_makeMealEntry());
      expect(provider.dailyLog, isNull);
    });

    test('removeMealEntry removes meal at index', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(name: 'First'));
      await Future.delayed(Duration.zero);
      await provider.addMealEntry(_makeMealEntry(name: 'Second'));
      await Future.delayed(Duration.zero);

      await provider.removeMealEntry(0);
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog!.meals, hasLength(1));
      expect(provider.dailyLog!.meals.first.name, 'Second');
    });

    test('removeMealEntry does nothing for invalid index', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(name: 'Only'));
      await Future.delayed(Duration.zero);

      await provider.removeMealEntry(5); // out of bounds
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog!.meals, hasLength(1));
    });

    test('removeMealEntry does nothing when no log exists', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.removeMealEntry(0);
      // Should not throw
    });

    test('addWater creates new log if none exists', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addWater(250);
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog, isNotNull);
      expect(provider.dailyLog!.waterMl, 250);
    });

    test('addWater adds to existing water', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addWater(250);
      await Future.delayed(Duration.zero);

      await provider.addWater(500);
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog!.waterMl, 750);
    });

    test('addWater does nothing when userId is null', () async {
      await provider.addWater(250);
      expect(provider.dailyLog, isNull);
    });

    test('removeWater reduces water amount', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addWater(500);
      await Future.delayed(Duration.zero);

      await provider.removeWater(200);
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog!.waterMl, 300);
    });

    test('removeWater does not go below 0', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addWater(100);
      await Future.delayed(Duration.zero);

      await provider.removeWater(500);
      await Future.delayed(Duration.zero);

      expect(provider.dailyLog!.waterMl, 0);
    });

    test('removeWater does nothing when userId is null', () async {
      await provider.removeWater(100);
      // Should not throw
    });

    test('totalCalories computes from meals', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(calories: 200));
      await Future.delayed(Duration.zero);
      await provider.addMealEntry(_makeMealEntry(calories: 300));
      await Future.delayed(Duration.zero);

      expect(provider.totalCalories, 500);
    });

    test('totalProtein computes from meals', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(protein: 10));
      await Future.delayed(Duration.zero);
      await provider.addMealEntry(_makeMealEntry(protein: 15));
      await Future.delayed(Duration.zero);

      expect(provider.totalProtein, 25);
    });

    test('totalCarbs computes from meals', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(carbs: 30));
      await Future.delayed(Duration.zero);
      await provider.addMealEntry(_makeMealEntry(carbs: 20));
      await Future.delayed(Duration.zero);

      expect(provider.totalCarbs, 50);
    });

    test('totalFat computes from meals', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(fat: 5));
      await Future.delayed(Duration.zero);
      await provider.addMealEntry(_makeMealEntry(fat: 10));
      await Future.delayed(Duration.zero);

      expect(provider.totalFat, 15);
    });

    test('calorieProgress uses default goal of 2000', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(calories: 1000));
      await Future.delayed(Duration.zero);

      expect(provider.calorieProgress(), 0.5);
    });

    test('proteinProgress uses default goal of 50', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(protein: 25));
      await Future.delayed(Duration.zero);

      expect(provider.proteinProgress(), 0.5);
    });

    test('carbsProgress uses default goal of 250', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(carbs: 125));
      await Future.delayed(Duration.zero);

      expect(provider.carbsProgress(), 0.5);
    });

    test('fatProgress uses default goal of 65', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(_makeMealEntry(fat: 32.5));
      await Future.delayed(Duration.zero);

      expect(provider.fatProgress(), 0.5);
    });

    test('progress clamps to max 1.5', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      // Exceeding 150% of default 2000 cal target
      await provider.addMealEntry(_makeMealEntry(calories: 4000));
      await Future.delayed(Duration.zero);

      expect(provider.calorieProgress(), 1.5);
    });

    test('saveNutritionGoal saves to Firestore', () async {
      final goal = NutritionGoal(
        userId: userId,
        calorieTarget: 2500,
        proteinTarget: 100,
        carbsTarget: 300,
        fatTarget: 80,
      );

      await provider.saveNutritionGoal(goal);

      final doc =
          await fakeFirestore.collection('nutrition_goals').doc(userId).get();
      expect(doc.exists, true);
      expect(doc.data()!['calorieTarget'], 2500);
    });

    test('mealsOfType filters by meal type', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.addMealEntry(
          _makeMealEntry(name: 'Eggs', mealType: MealType.breakfast));
      await Future.delayed(Duration.zero);
      await provider.addMealEntry(
          _makeMealEntry(name: 'Sandwich', mealType: MealType.lunch));
      await Future.delayed(Duration.zero);
      await provider.addMealEntry(
          _makeMealEntry(name: 'Toast', mealType: MealType.breakfast));
      await Future.delayed(Duration.zero);

      final breakfastMeals = provider.mealsOfType(MealType.breakfast);
      expect(breakfastMeals, hasLength(2));

      final lunchMeals = provider.mealsOfType(MealType.lunch);
      expect(lunchMeals, hasLength(1));

      final dinnerMeals = provider.mealsOfType(MealType.dinner);
      expect(dinnerMeals, isEmpty);
    });

    test('mealsOfType returns empty when no log', () {
      expect(provider.mealsOfType(MealType.breakfast), isEmpty);
    });

    test('dateString formats correctly', () {
      provider.init(userId);
      // The provider uses DateTime.now() for selectedDate, but we can set it
      provider.setDate(DateTime(2025, 3, 15));
      expect(provider.dateString, '2025-03-15');
    });
  });
}

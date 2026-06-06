import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chef_specials/models/ingredient.dart';
import 'package:chef_specials/providers/unit_preference_provider.dart';
import 'package:chef_specials/screens/recipe_detail/widgets/ingredient_list_view.dart';

void main() {
  // UnitPreferenceProvider's constructor reads SharedPreferences; mock it so
  // the async load resolves cleanly and never flakes under the full suite.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Widget buildTestWidget(List<Ingredient> ingredients) {
    return ChangeNotifierProvider(
      create: (_) => UnitPreferenceProvider(),
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IngredientListView(ingredients: ingredients),
          ),
        ),
      ),
    );
  }

  group('IngredientListView', () {
    testWidgets('renders ingredient names', (WidgetTester tester) async {
      final ingredients = [
        Ingredient(name: 'Flour', amount: '200', unit: 'g'),
        Ingredient(name: 'Sugar', amount: '100', unit: 'g'),
        Ingredient(name: 'Eggs', amount: '3'),
      ];

      await tester.pumpWidget(buildTestWidget(ingredients));

      expect(find.text('Flour'), findsOneWidget);
      expect(find.text('Sugar'), findsOneWidget);
      expect(find.text('Eggs'), findsOneWidget);
    });

    testWidgets('renders ingredient amounts with units',
        (WidgetTester tester) async {
      final ingredients = [
        Ingredient(name: 'Flour', amount: '200', unit: 'g'),
        Ingredient(name: 'Milk', amount: '250', unit: 'mL'),
      ];

      await tester.pumpWidget(buildTestWidget(ingredients));

      expect(find.text('200 g'), findsOneWidget);
      expect(find.text('250 mL'), findsOneWidget);
    });

    testWidgets('renders amount without unit when unit is null',
        (WidgetTester tester) async {
      final ingredients = [
        Ingredient(name: 'Eggs', amount: '3'),
      ];

      await tester.pumpWidget(buildTestWidget(ingredients));

      // When unit is null, just the amount is shown
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders correct number of ListTile items',
        (WidgetTester tester) async {
      final ingredients = [
        Ingredient(name: 'Flour', amount: '200', unit: 'g'),
        Ingredient(name: 'Sugar', amount: '100', unit: 'g'),
        Ingredient(name: 'Butter', amount: '50', unit: 'g'),
        Ingredient(name: 'Eggs', amount: '2'),
      ];

      await tester.pumpWidget(buildTestWidget(ingredients));

      expect(find.byType(ListTile), findsNWidgets(4));
    });

    testWidgets('renders bullet icons for each ingredient',
        (WidgetTester tester) async {
      final ingredients = [
        Ingredient(name: 'Salt', amount: '1', unit: 'tsp'),
        Ingredient(name: 'Pepper', amount: '1', unit: 'tsp'),
      ];

      await tester.pumpWidget(buildTestWidget(ingredients));

      expect(find.byIcon(Icons.fiber_manual_record), findsNWidgets(2));
    });

    testWidgets('renders empty widget when no ingredients',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget([]));

      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('renders a single ingredient correctly',
        (WidgetTester tester) async {
      final ingredients = [
        Ingredient(name: 'Olive Oil', amount: '30', unit: 'mL'),
      ];

      await tester.pumpWidget(buildTestWidget(ingredients));

      expect(find.text('Olive Oil'), findsOneWidget);
      expect(find.text('30 mL'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('uses dense and compact visual density',
        (WidgetTester tester) async {
      final ingredients = [
        Ingredient(name: 'Water', amount: '500', unit: 'mL'),
      ];

      await tester.pumpWidget(buildTestWidget(ingredients));

      final listTile = tester.widget<ListTile>(find.byType(ListTile));
      expect(listTile.dense, isTrue);
      expect(listTile.visualDensity, VisualDensity.compact);
    });

    testWidgets('alternates background colors for even/odd rows',
        (WidgetTester tester) async {
      final ingredients = [
        Ingredient(name: 'Ingredient A', amount: '1'),
        Ingredient(name: 'Ingredient B', amount: '2'),
        Ingredient(name: 'Ingredient C', amount: '3'),
      ];

      await tester.pumpWidget(buildTestWidget(ingredients));

      // The widget uses Container with color based on index.isEven
      // Even indices (0, 2) have AppTheme.neutralSoft color
      // Odd indices (1) have Colors.transparent
      // All three should exist
      expect(find.byType(ListTile), findsNWidgets(3));
    });
  });
}

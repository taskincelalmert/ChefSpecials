import 'dart:io';
import 'package:flutter/material.dart';
import '../models/ingredient.dart';
import '../utils/unit_converter.dart';
import '../models/recipe_step.dart';
import '../models/recipe.dart';
import '../models/food_item.dart';
import '../services/storage_service.dart';

class RecipeFormProvider extends ChangeNotifier {
  final StorageService _storageService;

  RecipeFormProvider({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  String title = '';
  String description = '';
  String category = 'Breakfast';
  int servings = 1;
  int prepTimeMinutes = 10;
  int cookTimeMinutes = 0;
  File? imageFile;
  String? existingImageUrl;
  File? videoFile;
  String? existingVideoUrl;
  List<Ingredient> ingredients = [];
  List<RecipeStep> steps = [RecipeStep(order: 1, instruction: '')];
  Map<int, File> stepVideoFiles = {};
  int? caloriesPerServing;
  double? proteinGrams;
  double? carbsGrams;
  double? fatGrams;
  bool isPrivate = false;
  List<String> dietaryTags = [];
  List<File> additionalPhotoFiles = [];
  List<String> existingAdditionalPhotos = [];
  bool isSubmitting = false;

  void prefillFromRecipe(Recipe recipe) {
    title = recipe.title;
    description = recipe.description;
    category = recipe.category;
    servings = recipe.servings;
    prepTimeMinutes = recipe.prepTimeMinutes;
    cookTimeMinutes = recipe.cookTimeMinutes;
    ingredients = List.from(recipe.ingredients);
    steps = recipe.steps.isEmpty
        ? [RecipeStep(order: 1, instruction: '')]
        : List.from(recipe.steps);
    if (recipe.imageUrl != null) existingImageUrl = recipe.imageUrl;
    existingAdditionalPhotos = List.from(recipe.photos);
    existingVideoUrl = recipe.videoUrl;
    notifyListeners();
  }

  void setVideoFile(File file) {
    videoFile = file;
    existingVideoUrl = null;
    notifyListeners();
  }

  void clearVideo() {
    videoFile = null;
    existingVideoUrl = null;
    notifyListeners();
  }

  void setStepVideoFile(int index, File file) {
    stepVideoFiles[index] = file;
    notifyListeners();
  }

  void removeStepVideoFile(int index) {
    stepVideoFiles.remove(index);
    notifyListeners();
  }

  void addIngredientFromFoodItem(FoodItem foodItem, String amount) {
    ingredients.add(Ingredient(
      name: foodItem.name,
      amount: amount,
      unit: UnitConverter.isVolumeUnit(foodItem.unit) ? 'mL' : 'g',
      foodItemId: foodItem.id,
      caloriesPer100: foodItem.calories,
      proteinPer100: foodItem.protein,
      carbsPer100: foodItem.carbs,
      fatPer100: foodItem.fat,
    ));
    _recalculateNutrition();
    notifyListeners();
  }

  void addManualIngredient(String name, String amount, String unit) {
    ingredients.add(Ingredient(
      name: name,
      amount: amount,
      unit: unit,
    ));
    _recalculateNutrition();
    notifyListeners();
  }

  void updateIngredientAmount(int index, String amount) {
    final old = ingredients[index];
    ingredients[index] = Ingredient(
      name: old.name,
      amount: amount,
      unit: old.unit,
      foodItemId: old.foodItemId,
      caloriesPer100: old.caloriesPer100,
      proteinPer100: old.proteinPer100,
      carbsPer100: old.carbsPer100,
      fatPer100: old.fatPer100,
    );
    _recalculateNutrition();
    notifyListeners();
  }

  void removeIngredient(int index) {
    ingredients.removeAt(index);
    _recalculateNutrition();
    notifyListeners();
  }

  void _recalculateNutrition() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final ing in ingredients) {
      final grams = double.tryParse(ing.amount) ?? 0;
      final ratio = grams / 100.0;
      totalCalories += (ing.caloriesPer100 ?? 0) * ratio;
      totalProtein += (ing.proteinPer100 ?? 0) * ratio;
      totalCarbs += (ing.carbsPer100 ?? 0) * ratio;
      totalFat += (ing.fatPer100 ?? 0) * ratio;
    }

    final s = servings > 0 ? servings : 1;
    caloriesPerServing = (totalCalories / s).round();
    proteinGrams = double.parse((totalProtein / s).toStringAsFixed(1));
    carbsGrams = double.parse((totalCarbs / s).toStringAsFixed(1));
    fatGrams = double.parse((totalFat / s).toStringAsFixed(1));
  }

  void addStep() {
    steps.add(RecipeStep(order: steps.length + 1, instruction: ''));
    notifyListeners();
  }

  void removeStep(int index) {
    if (steps.length > 1) {
      steps.removeAt(index);
      // Shift step video file indices
      final shifted = <int, File>{};
      for (final entry in stepVideoFiles.entries) {
        if (entry.key < index) {
          shifted[entry.key] = entry.value;
        } else if (entry.key > index) {
          shifted[entry.key - 1] = entry.value;
        }
      }
      stepVideoFiles = shifted;
      for (int i = 0; i < steps.length; i++) {
        steps[i] = RecipeStep(
          order: i + 1,
          instruction: steps[i].instruction,
          imageUrl: steps[i].imageUrl,
          timerSeconds: steps[i].timerSeconds,
          videoUrl: steps[i].videoUrl,
        );
      }
      notifyListeners();
    }
  }

  void updateStep(int index, {String? instruction, int? timerSeconds}) {
    final old = steps[index];
    steps[index] = RecipeStep(
      order: old.order,
      instruction: instruction ?? old.instruction,
      imageUrl: old.imageUrl,
      timerSeconds: timerSeconds ?? old.timerSeconds,
      videoUrl: old.videoUrl,
    );
    notifyListeners();
  }

  void setImage(File file) {
    imageFile = file;
    notifyListeners();
  }

  void clearCoverImage() {
    imageFile = null;
    existingImageUrl = null;
    notifyListeners();
  }

  void addAdditionalPhotos(List<File> files) {
    additionalPhotoFiles.addAll(files);
    notifyListeners();
  }

  void removeAdditionalPhoto(int index) {
    if (index < existingAdditionalPhotos.length) {
      existingAdditionalPhotos.removeAt(index);
    } else {
      additionalPhotoFiles.removeAt(index - existingAdditionalPhotos.length);
    }
    notifyListeners();
  }

  void reorderAdditionalPhotos(int oldIndex, int newIndex) {
    final totalExisting = existingAdditionalPhotos.length;
    final allUrls = [...existingAdditionalPhotos];
    final allFiles = [...additionalPhotoFiles];

    if (oldIndex < totalExisting && newIndex < totalExisting) {
      final item = allUrls.removeAt(oldIndex);
      allUrls.insert(newIndex, item);
      existingAdditionalPhotos = allUrls;
    } else if (oldIndex >= totalExisting && newIndex >= totalExisting) {
      final fi = oldIndex - totalExisting;
      final ti = newIndex - totalExisting;
      final item = allFiles.removeAt(fi);
      allFiles.insert(ti, item);
      additionalPhotoFiles = allFiles;
    }
    notifyListeners();
  }

  void setIsPrivate(bool value) {
    isPrivate = value;
    notifyListeners();
  }

  void toggleDietaryTag(String tag) {
    if (dietaryTags.contains(tag)) {
      dietaryTags.remove(tag);
    } else {
      dietaryTags.add(tag);
    }
    notifyListeners();
  }

  void loadFromRecipe(Recipe recipe) {
    title = recipe.title;
    description = recipe.description;
    category = recipe.category;
    servings = recipe.servings;
    prepTimeMinutes = recipe.prepTimeMinutes;
    cookTimeMinutes = recipe.cookTimeMinutes;
    existingImageUrl = recipe.imageUrl;
    existingVideoUrl = recipe.videoUrl;
    ingredients = List.from(recipe.ingredients);
    steps = recipe.steps.isNotEmpty
        ? List.from(recipe.steps)
        : [RecipeStep(order: 1, instruction: '')];
    caloriesPerServing = recipe.caloriesPerServing;
    proteinGrams = recipe.proteinGrams;
    carbsGrams = recipe.carbsGrams;
    fatGrams = recipe.fatGrams;
    isPrivate = recipe.isPrivate;
    dietaryTags = List.from(recipe.dietaryTags);
    existingAdditionalPhotos = List.from(recipe.photos);
    additionalPhotoFiles = [];
    stepVideoFiles = {};
    notifyListeners();
  }

  Future<Recipe> buildRecipe(String authorId, String authorName) async {
    isSubmitting = true;
    notifyListeners();

    try {
      String? imageUrl = existingImageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadRecipeImage(imageFile!, authorId);
      }

      String? recipeVideoUrl = existingVideoUrl;
      if (videoFile != null) {
        recipeVideoUrl = await _storageService.uploadRecipeVideo(videoFile!, authorId);
      }

      final List<String> allPhotos = List.from(existingAdditionalPhotos);
      if (additionalPhotoFiles.isNotEmpty) {
        final uploaded = await _storageService.uploadRecipePhotos(
          authorId,
          additionalPhotoFiles,
        );
        allPhotos.addAll(uploaded);
      }

      final validIngredients = ingredients
          .where((i) => i.name.isNotEmpty && i.amount.isNotEmpty)
          .toList();
      final rawValidSteps = steps
          .where((s) => s.instruction.isNotEmpty)
          .toList();

      // Upload step videos
      final processedSteps = <RecipeStep>[];
      for (int i = 0; i < rawValidSteps.length; i++) {
        final step = rawValidSteps[i];
        final stepVideoFile = stepVideoFiles[steps.indexOf(step)];
        String? stepVideoUrl = step.videoUrl;
        if (stepVideoFile != null) {
          stepVideoUrl = await _storageService.uploadStepVideo(stepVideoFile, authorId);
        }
        processedSteps.add(RecipeStep(
          order: step.order,
          instruction: step.instruction,
          imageUrl: step.imageUrl,
          timerSeconds: step.timerSeconds,
          videoUrl: stepVideoUrl,
        ));
      }

      return Recipe(
        title: title,
        description: description,
        authorId: authorId,
        authorName: authorName,
        category: category,
        servings: servings,
        prepTimeMinutes: prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes,
        imageUrl: imageUrl,
        ingredients: validIngredients,
        steps: processedSteps,
        caloriesPerServing: caloriesPerServing,
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatGrams: fatGrams,
        createdAt: DateTime.now(),
        isPrivate: isPrivate,
        dietaryTags: dietaryTags,
        photos: allPhotos,
        videoUrl: recipeVideoUrl,
      );
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void reset() {
    title = '';
    description = '';
    category = 'Breakfast';
    servings = 1;
    prepTimeMinutes = 10;
    cookTimeMinutes = 0;
    imageFile = null;
    existingImageUrl = null;
    videoFile = null;
    existingVideoUrl = null;
    ingredients = [];
    steps = [RecipeStep(order: 1, instruction: '')];
    stepVideoFiles = {};
    caloriesPerServing = null;
    proteinGrams = null;
    carbsGrams = null;
    fatGrams = null;
    isPrivate = false;
    dietaryTags = [];
    additionalPhotoFiles = [];
    existingAdditionalPhotos = [];
    isSubmitting = false;
    notifyListeners();
  }
}

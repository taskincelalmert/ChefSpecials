import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/food_item.dart';
import '../../../providers/recipe_form_provider.dart';
import '../../../services/food_item_service.dart';
import '../../../utils/unit_converter.dart';
import '../../../widgets/unit_converter_sheet.dart';

class IngredientInputList extends StatelessWidget {
  const IngredientInputList({super.key});

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<RecipeFormProvider>();
    final l10n = AppLocalizations.of(context)!;
    final ingredients = formProvider.ingredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.egg_alt,
                  color: AppTheme.secondaryColor, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.ingredients.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiaryOf(context),
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showFoodItemPicker(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 16, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      l10n.addButton,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (ingredients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.neutralSoftOf(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Icon(Icons.egg_alt, size: 32, color: AppTheme.neutralLightOf(context)),
                const SizedBox(height: 8),
                Text(
                  l10n.tapToAddIngredients,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textTertiaryOf(context),
                  ),
                ),
              ],
            ),
          ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ingredients.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final ingredient = ingredients[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ingredient.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (ingredient.caloriesPer100 != null)
                          Text(
                            '${ingredient.caloriesPer100!.toStringAsFixed(0)} kcal / 100${ingredient.unit ?? 'g'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textTertiaryOf(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 72,
                    child: TextFormField(
                      initialValue: ingredient.amount,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        suffixText: ingredient.unit ?? 'g',
                        suffixStyle: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiaryOf(context),
                        ),
                        filled: true,
                        fillColor: AppTheme.neutralSoftOf(context),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppTheme.primaryColor, width: 1.5),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          formProvider.updateIngredientAmount(index, value),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      final parsed = double.tryParse(ingredient.amount);
                      UnitConverterSheet.show(
                        context,
                        initialValue: parsed,
                        initialUnit: ingredient.unit,
                      );
                    },
                    child: Icon(
                      Icons.swap_horiz,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => formProvider.removeIngredient(index),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppTheme.textTertiaryOf(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showFoodItemPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => _FoodItemPickerSheet(
          scrollController: scrollController,
          onSelected: (foodItem) {
            Navigator.pop(sheetContext);
            _showAmountDialog(context, foodItem);
          },
          onManualAdd: (initialName) {
            Navigator.pop(sheetContext);
            _showManualIngredientDialog(context, initialName);
          },
        ),
      ),
    );
  }

  void _showManualIngredientDialog(BuildContext context, String initialName) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: initialName);
    final amountController = TextEditingController(text: '100');
    const units = ['g', 'mL', 'pcs', 'cups', 'tbsp', 'tsp'];

    showDialog(
      context: context,
      builder: (dialogContext) {
        String selectedUnit = 'g';
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                l10n.customIngredient,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.ingredientName,
                      prefixIcon: Icon(
                        Icons.edit_note,
                        color: AppTheme.textTertiaryOf(dialogContext),
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: initialName.isEmpty,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: l10n.quantity,
                            prefixIcon: Icon(
                              Icons.scale,
                              color: AppTheme.textTertiaryOf(dialogContext),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedUnit,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.unit,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                          items: units
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => selectedUnit = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final amount = amountController.text.trim();
                    if (name.isEmpty || amount.isEmpty) return;
                    if (double.tryParse(amount) == null) return;
                    context
                        .read<RecipeFormProvider>()
                        .addManualIngredient(name, amount, selectedUnit);
                    Navigator.pop(dialogContext);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAmountDialog(BuildContext context, FoodItem foodItem) {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController(text: '100');
    final isWeight = foodItem.unit == '100g';
    final baseUnit = isWeight ? 'g' : 'mL';

    final weightUnits = ['g', 'kg', 'oz', 'lb'];
    final volumeUnits = ['mL', 'L', 'cups', 'tbsp', 'tsp', 'fl oz'];
    final unitOptions = isWeight ? weightUnits : volumeUnits;

    showDialog(
      context: context,
      builder: (dialogContext) {
        String selectedUnit = baseUnit;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                foodItem.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.neutralSoftOf(dialogContext),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${foodItem.calories.toStringAsFixed(0)} kcal, '
                      '${foodItem.protein.toStringAsFixed(1)}g protein / 100$baseUnit',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(dialogContext),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: amountController,
                          decoration: InputDecoration(
                            labelText: l10n.quantity,
                            prefixIcon: Icon(
                              Icons.scale,
                              color: AppTheme.textTertiaryOf(dialogContext),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          autofocus: true,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedUnit,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.fromUnit,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 12),
                          ),
                          items: unitOptions
                              .map((u) =>
                                  DropdownMenuItem(value: u, child: Text(u)))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => selectedUnit = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (selectedUnit != baseUnit)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${l10n.tapToConvert}: → $baseUnit',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textTertiaryOf(dialogContext),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final rawAmount = amountController.text.trim();
                    if (rawAmount.isEmpty) return;
                    final parsed = double.tryParse(rawAmount);
                    if (parsed == null) return;

                    double converted = parsed;
                    if (selectedUnit != baseUnit) {
                      if (isWeight) {
                        final from = _parseWeightUnit(selectedUnit);
                        final to = _parseWeightUnit(baseUnit);
                        if (from != null && to != null) {
                          converted =
                              UnitConverter.convertWeight(parsed, from, to);
                        }
                      } else {
                        final from = _parseVolumeUnit(selectedUnit);
                        final to = _parseVolumeUnit(baseUnit);
                        if (from != null && to != null) {
                          converted =
                              UnitConverter.convertVolume(parsed, from, to);
                        }
                      }
                    }

                    final finalAmount = converted == converted.roundToDouble()
                        ? converted.toInt().toString()
                        : converted.toStringAsFixed(1);

                    context
                        .read<RecipeFormProvider>()
                        .addIngredientFromFoodItem(foodItem, finalAmount);
                    Navigator.pop(dialogContext);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static WeightUnit? _parseWeightUnit(String label) {
    switch (label) {
      case 'g':
        return WeightUnit.g;
      case 'kg':
        return WeightUnit.kg;
      case 'oz':
        return WeightUnit.oz;
      case 'lb':
        return WeightUnit.lb;
      default:
        return null;
    }
  }

  static VolumeUnit? _parseVolumeUnit(String label) {
    switch (label) {
      case 'mL':
        return VolumeUnit.mL;
      case 'L':
        return VolumeUnit.L;
      case 'cups':
        return VolumeUnit.cups;
      case 'tbsp':
        return VolumeUnit.tbsp;
      case 'tsp':
        return VolumeUnit.tsp;
      case 'fl oz':
        return VolumeUnit.flOz;
      default:
        return null;
    }
  }
}

class _FoodItemPickerSheet extends StatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<FoodItem> onSelected;
  final ValueChanged<String> onManualAdd;

  const _FoodItemPickerSheet({
    required this.scrollController,
    required this.onSelected,
    required this.onManualAdd,
  });

  @override
  State<_FoodItemPickerSheet> createState() => _FoodItemPickerSheetState();
}

class _FoodItemPickerSheetState extends State<_FoodItemPickerSheet> {
  final FoodItemService _service = FoodItemService();
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _items = [];
  List<FoodItem> _filtered = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    _service.getFoodItems().listen((items) {
      if (mounted) {
        setState(() {
          _items = items;
          _filtered = items;
          _isLoading = false;
        });
      }
    });
  }

  void _search(String query) {
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _filtered = _items;
      } else {
        final lower = query.toLowerCase();
        _filtered = _items
            .where((item) => item.name.toLowerCase().contains(lower))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.neutralLightOf(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.neutralLightOf(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search, color: AppTheme.textTertiaryOf(context), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.searchMaterials,
                      hintStyle: TextStyle(
                        color: AppTheme.textTertiaryOf(context),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: _search,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Manual add option — lets the user add an ingredient that isn't
        // in the food items list by typing its name.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GestureDetector(
            onTap: () => widget.onManualAdd(_query.trim()),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.edit_note,
                        color: AppTheme.primaryColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _query.trim().isEmpty
                          ? AppLocalizations.of(context)!.addManually
                          : AppLocalizations.of(context)!
                              .addCustomIngredient(_query.trim()),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const Icon(Icons.add,
                      color: AppTheme.primaryColor, size: 20),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.kitchen,
                              size: 48, color: AppTheme.neutralLightOf(context)),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context)!.noMaterialsFound,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textTertiaryOf(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: widget.scrollController,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        return GestureDetector(
                          onTap: () => widget.onSelected(item),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceOf(context),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${item.calories.toStringAsFixed(0)} kcal · '
                                        '${item.protein.toStringAsFixed(1)}g P · '
                                        '${item.carbs.toStringAsFixed(1)}g C · '
                                        '${item.fat.toStringAsFixed(1)}g F',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textTertiaryOf(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textTertiaryOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

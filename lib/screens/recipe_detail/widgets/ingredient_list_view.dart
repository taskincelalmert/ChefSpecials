import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/ingredient.dart';
import '../../../providers/unit_preference_provider.dart';
import '../../../utils/unit_converter.dart';

class IngredientListView extends StatelessWidget {
  final List<Ingredient> ingredients;
  final double? scaleFactor;

  const IngredientListView({
    super.key,
    required this.ingredients,
    this.scaleFactor,
  });

  String _formatAmount(Ingredient ingredient, bool isMetric) {
    final unit = ingredient.unit ?? '';
    final parsed = double.tryParse(ingredient.amount);

    if (parsed == null) {
      return unit.isNotEmpty ? '${ingredient.amount} $unit' : ingredient.amount;
    }

    final scaled = scaleFactor != null ? parsed * scaleFactor! : parsed;
    return UnitConverter.formatWithPreference(scaled, unit, isMetric);
  }

  void _toggleUnits(BuildContext context) {
    final provider = context.read<UnitPreferenceProvider>();
    provider.toggleUnitSystem();

    final l10n = AppLocalizations.of(context)!;
    final label = provider.isMetric ? l10n.metric : l10n.imperial;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${l10n.units}: $label'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isMetric = context.watch<UnitPreferenceProvider>().isMetric;

    return Column(
      children: List.generate(ingredients.length, (index) {
        final ingredient = ingredients[index];
        final subtitle = _formatAmount(ingredient, isMetric);

        return Container(
          color: index.isEven ? AppTheme.neutralSoft : Colors.transparent,
          child: ListTile(
            leading: const Icon(Icons.fiber_manual_record, size: 10, color: AppTheme.primaryColor),
            title: Text(
              ingredient.name,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
            trailing: Text(
              subtitle,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            onTap: () => _toggleUnits(context),
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        );
      }),
    );
  }
}

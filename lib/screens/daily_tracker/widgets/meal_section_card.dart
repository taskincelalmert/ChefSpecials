import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/meal_entry.dart';

class MealSectionCard extends StatefulWidget {
  final MealType mealType;
  final List<MealEntry> entries;
  final VoidCallback onAddPressed;
  final Function(int) onRemoveEntry;

  const MealSectionCard({
    super.key,
    required this.mealType,
    required this.entries,
    required this.onAddPressed,
    required this.onRemoveEntry,
  });

  @override
  State<MealSectionCard> createState() => _MealSectionCardState();
}

class _MealSectionCardState extends State<MealSectionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.entries.isNotEmpty;
  }

  IconData _iconForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.coffee;
      case MealType.lunch:
        return Icons.lunch_dining;
      case MealType.dinner:
        return Icons.dinner_dining;
      case MealType.snack:
        return Icons.eco;
    }
  }

  Color _colorForMealType(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return AppTheme.breakfastColor;
      case MealType.lunch:
        return AppTheme.lunchColor;
      case MealType.dinner:
        return AppTheme.dinnerColor;
      case MealType.snack:
        return AppTheme.snackColor;
    }
  }

  String _mealTypeName(AppLocalizations l10n, MealType type) {
    switch (type) {
      case MealType.breakfast:
        return l10n.breakfast;
      case MealType.lunch:
        return l10n.lunch;
      case MealType.dinner:
        return l10n.dinner;
      case MealType.snack:
        return l10n.snack;
    }
  }

  double _totalCalories() {
    return widget.entries.fold(0, (sum, e) => sum + e.calories);
  }

  Widget _buildEntryList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        children: List.generate(widget.entries.length, (index) {
          final entry = widget.entries[index];
          return Dismissible(
            key: ValueKey(entry.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: AppTheme.errorColor,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 20,
              ),
            ),
            onDismissed: (_) => widget.onRemoveEntry(index),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${entry.name} (${entry.quantity.toInt()}${entry.unit})',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryOf(context),
                      ),
                    ),
                  ),
                  Text(
                    '${entry.calories.toInt()} ${AppLocalizations.of(context)!.kcal}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalCal = _totalCalories();
    final hasEntries = widget.entries.isNotEmpty;
    final color = _colorForMealType(widget.mealType);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceOf(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
          ),
          boxShadow: [AppTheme.shadowOf(context)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Tappable header area (everything except add button)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          // Icon
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _iconForMealType(widget.mealType),
                              color: color,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Title + subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _mealTypeName(l10n, widget.mealType),
                                  style:
                                      Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasEntries
                                      ? '${totalCal.toInt()} ${l10n.kcal}'
                                      : l10n.notAddedYet,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textTertiaryOf(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Animated chevron
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.expand_more,
                              color: AppTheme.textTertiaryOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Add button
                  Material(
                    color: AppTheme.primaryColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: widget.onAddPressed,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 30,
                        height: 30,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Expandable entry list
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: hasEntries
                  ? _buildEntryList(context)
                  : const SizedBox.shrink(),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}

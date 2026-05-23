import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../models/recipe_step.dart';
import '../../../widgets/video_player_widget.dart';
import 'countdown_timer_widget.dart';

class StepPage extends StatelessWidget {
  final RecipeStep step;
  final int totalSteps;
  final bool isCompleted;
  final VoidCallback onToggle;

  const StepPage({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step number badge with gradient
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Step ${step.order} of $totalSteps',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Step video (takes priority over image when available)
          if (step.videoUrl != null && step.videoUrl!.isNotEmpty) ...[
            VideoPlayerWidget(videoUrl: step.videoUrl!),
            const SizedBox(height: 24),
          ] else if (step.imageUrl != null && step.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: step.imageUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 60),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Instruction card with warm styling
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.neutralSoftOf(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5),
              ),
              boxShadow: [AppTheme.shadowOf(context)],
            ),
            child: Text(
              step.instruction,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Timer
          if (step.timerSeconds != null && step.timerSeconds! > 0)
            CountdownTimerWidget(totalSeconds: step.timerSeconds!),

          const SizedBox(height: 24),

          // Done checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.primaryColor.withValues(alpha: 0.12)
                    : AppTheme.neutralSoftOf(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.primaryColor
                      : AppTheme.neutralLightOf(context),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      key: ValueKey(isCompleted),
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : AppTheme.neutralLightOf(context),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)!.stepCompleted,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isCompleted
                          ? AppTheme.primaryColor
                          : theme.textTheme.bodyMedium?.color,
                      fontWeight: isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

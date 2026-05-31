import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/recipe_form_provider.dart';

class StepInputList extends StatelessWidget {
  const StepInputList({super.key});

  Future<void> _pickStepVideo(
      BuildContext context, int index, RecipeFormProvider formProvider) async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null && context.mounted) {
      formProvider.setStepVideoFile(index, File(video.path));
    }
  }

  Widget _buildVideoRow(
    BuildContext context,
    int index,
    RecipeFormProvider formProvider,
    AppLocalizations l10n,
  ) {
    final hasVideo = formProvider.stepVideoFiles.containsKey(index);
    return Row(
      children: [
        GestureDetector(
          onTap: () => _pickStepVideo(context, index, formProvider),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: hasVideo
                  ? AppTheme.primaryColor.withValues(alpha: 0.08)
                  : AppTheme.neutralSoftOf(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasVideo
                    ? AppTheme.primaryColor.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.video_library_outlined,
                  size: 14,
                  color: hasVideo
                      ? AppTheme.primaryColor
                      : AppTheme.textTertiaryOf(context),
                ),
                const SizedBox(width: 5),
                Text(
                  hasVideo ? l10n.stepVideo : l10n.addVideo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight:
                        hasVideo ? FontWeight.w600 : FontWeight.w400,
                    color: hasVideo
                        ? AppTheme.primaryColor
                        : AppTheme.textTertiaryOf(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (hasVideo) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => formProvider.removeStepVideoFile(index),
            child: Icon(
              Icons.close,
              size: 14,
              color: AppTheme.textTertiaryOf(context),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = context.watch<RecipeFormProvider>();
    final l10n = AppLocalizations.of(context)!;
    final steps = formProvider.steps;

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
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.list_alt,
                  color: Color(0xFFF59E0B), size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.steps.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textTertiaryOf(context),
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: formProvider.addStep,
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
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final step = steps[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceOf(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neutralLightOf(context).withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: step.instruction,
                          decoration: InputDecoration(
                            hintText: l10n.instruction,
                            hintStyle: TextStyle(
                              color: AppTheme.textTertiaryOf(context),
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: AppTheme.neutralSoftOf(context),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: AppTheme.primaryColor, width: 1.5),
                            ),
                          ),
                          style: const TextStyle(fontSize: 13),
                          maxLines: 2,
                          onChanged: (value) => formProvider.updateStep(
                            index,
                            instruction: value,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildVideoRow(context, index, formProvider, l10n),
                      ],
                    ),
                  ),
                  if (steps.length > 1)
                    GestureDetector(
                      onTap: () => formProvider.removeStep(index),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: AppTheme.textTertiaryOf(context),
                        ),
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
}

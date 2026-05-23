import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/recipe.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cooking_log_provider.dart';
import 'widgets/step_page.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  late List<bool> _completedSteps;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _completedSteps = List.filled(widget.recipe.steps.length, false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onFinish(BuildContext context, AppLocalizations l10n) async {
    final isAuthenticated = context.read<AuthProvider>().isAuthenticated;
    if (!isAuthenticated) {
      context.pop();
      return;
    }

    int selectedServings = widget.recipe.servings;
    int selectedRating = 0;
    final notesController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.neutralLightOf(ctx),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        l10n.iCookedThis,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: List.generate(5, (i) {
                          return GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedRating = i + 1),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(
                                i < selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                size: 32,
                                color: AppTheme.starColor,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(l10n.serves(selectedServings),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: selectedServings > 1
                                ? () => setModalState(() => selectedServings--)
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: selectedServings < 20
                                ? () => setModalState(() => selectedServings++)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: l10n.personalNotes,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(l10n.skip),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                try {
                                  await context
                                      .read<CookingLogProvider>()
                                      .logCook(
                                        widget.recipe,
                                        personalRating: selectedRating > 0
                                            ? selectedRating
                                            : null,
                                        notes:
                                            notesController.text.trim().isEmpty
                                                ? null
                                                : notesController.text.trim(),
                                        servings: selectedServings,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(l10n.cookLogged),
                                    ));
                                  }
                                } catch (_) {}
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(l10n.logCook),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    // notesController is a local variable; do not dispose here because the
    // modal's exit animation is still running and TextField.dispose() will
    // call removeListener on it — disposing early causes a FlutterError.
    // The GC will reclaim it once _onFinish returns and all closures are gone.
    if (context.mounted) {
      // Let the modal's dismiss animation finish before popping this screen.
      await Future.delayed(const Duration(milliseconds: 300));
      if (context.mounted) context.pop();
    }
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = widget.recipe.steps;
    final isFirst = _currentPage == 0;
    final isLast = _currentPage == steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            width: double.infinity,
            color: AppTheme.neutralLightOf(context),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: steps.isEmpty ? 0 : (_currentPage + 1) / steps.length,
              child: Container(
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
      body: steps.isEmpty
          ? Center(child: Text(l10n.error))
          : PageView.builder(
              controller: _pageController,
              itemCount: steps.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return StepPage(
                  step: steps[index],
                  totalSteps: steps.length,
                  isCompleted: _completedSteps[index],
                  onToggle: () => setState(
                    () => _completedSteps[index] = !_completedSteps[index],
                  ),
                );
              },
            ),
      bottomNavigationBar: steps.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isFirst ? null : () => _goToPage(_currentPage - 1),
                        icon: const Icon(Icons.arrow_back),
                        label: Text(l10n.previous),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: isLast
                            ? () => _onFinish(context, l10n)
                            : () => _goToPage(_currentPage + 1),
                        icon: Icon(isLast ? Icons.check : Icons.arrow_forward),
                        label: Text(isLast ? l10n.done : l10n.next),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

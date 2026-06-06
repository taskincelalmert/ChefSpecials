import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/recipe.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trending_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/screen_header.dart';

class AdminRecipesScreen extends StatelessWidget {
  const AdminRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider(),
      child: const _RecipesBody(),
    );
  }
}

class _RecipesBody extends StatefulWidget {
  const _RecipesBody();

  @override
  State<_RecipesBody> createState() => _RecipesBodyState();
}

class _RecipesBodyState extends State<_RecipesBody> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadRecipes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    context.read<AdminProvider>().loadRecipes(searchQuery: query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<AdminProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundOf(context),
      body: Column(
        children: [
          ScreenHeader(
            title: l10n.recipeModeration,
            icon: Icons.restaurant_menu,
            iconColor: AppTheme.dinnerColor,
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.recipes.isEmpty
                    ? EmptyState(
                        icon: Icons.restaurant_menu,
                        title: l10n.noRecipes,
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.fromLTRB(16, 4, 16, 40),
                        itemCount: provider.recipes.length,
                        itemBuilder: (context, index) =>
                            _buildRecipeCard(
                                context, provider.recipes[index], l10n),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(
      BuildContext context, Recipe recipe, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(recipe.id ?? recipe.createdAt.toIso8601String()),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _confirmDelete(context, recipe, l10n),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 20),
              SizedBox(width: 6),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceOf(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.neutralLightOf(context)
                  .withValues(alpha: 0.5),
            ),
            boxShadow: [AppTheme.shadowOf(context)],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: recipe.imageUrl != null &&
                        recipe.imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: recipe.imageUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => _buildPlaceholder(context),
                        errorWidget: (_, _, _) =>
                            _buildPlaceholder(context),
                      )
                    : _buildPlaceholder(context),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimaryOf(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          recipe.authorName,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM d, yyyy')
                              .format(recipe.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating stars
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < recipe.averageRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: AppTheme.starColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${recipe.ratingCount})',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textTertiaryOf(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.neutralSoftOf(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.restaurant,
        size: 20,
        color: AppTheme.textTertiaryOf(context),
      ),
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context, Recipe recipe, AppLocalizations l10n) async {
    final authUser = context.read<AuthProvider>().userModel;
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => _DeleteRecipeDialog(l10n: l10n),
    );

    if (reason != null && context.mounted) {
      final trending = context.read<TrendingProvider>();
      await context.read<AdminProvider>().deleteRecipe(
            recipeId: recipe.id ?? '',
            recipeName: recipe.title,
            authorId: recipe.authorId,
            adminId: authUser?.uid ?? '',
            adminName: authUser?.fullName ?? '',
            description: reason,
          );
      // Keep the trending cache in sync so the deleted recipe doesn't linger
      // in the Home trending row (mirrors the owner-delete flow).
      trending.removeRecipe(recipe.id ?? '');
    }
    // Return false: AdminProvider.deleteRecipe already removes the item from
    // its list and notifies, so the ListView rebuild performs the visual
    // removal. Letting the Dismissible also dismiss would double-remove the
    // widget (crash); on failure the card correctly stays put.
    return false;
  }
}

class _DeleteRecipeDialog extends StatefulWidget {
  const _DeleteRecipeDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_DeleteRecipeDialog> createState() => _DeleteRecipeDialogState();
}

class _DeleteRecipeDialogState extends State<_DeleteRecipeDialog> {
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(l10n.delete),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.deleteRecipeConfirmAdmin),
          const SizedBox(height: 16),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: l10n.enterBanReason,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            final reason = _descController.text.trim();
            if (reason.isEmpty) return;
            Navigator.pop(context, reason);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.errorColor,
          ),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}

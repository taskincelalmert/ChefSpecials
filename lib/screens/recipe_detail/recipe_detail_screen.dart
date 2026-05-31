import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/comment.dart';
import '../../models/ingredient.dart';
import '../../models/recipe.dart';
import '../../models/recipe_step.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/comment_provider.dart';
import '../../providers/rating_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/recipe_provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../../providers/trending_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/cooking_log_provider.dart';
import '../../providers/block_provider.dart';
import '../../providers/like_provider.dart';
import '../../models/report.dart';
import '../../services/report_service.dart';
import '../../models/shopping_list.dart';
import '../../utils/category_helpers.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/photo_carousel.dart';
import '../../widgets/serving_size_selector.dart';
import '../../widgets/video_player_widget.dart';
import 'widgets/ingredient_list_view.dart';
import 'widgets/step_overview_list.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late final RatingProvider _ratingProvider;
  late final CommentProvider _commentProvider;

  @override
  void initState() {
    super.initState();
    _ratingProvider = RatingProvider();
    _commentProvider = CommentProvider();
  }

  @override
  void dispose() {
    _ratingProvider.dispose();
    _commentProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _ratingProvider),
        ChangeNotifierProvider.value(value: _commentProvider),
      ],
      child: _RecipeDetailBody(recipe: widget.recipe),
    );
  }
}

class _RecipeDetailBody extends StatefulWidget {
  final Recipe recipe;
  const _RecipeDetailBody({required this.recipe});

  @override
  State<_RecipeDetailBody> createState() => _RecipeDetailBodyState();
}

class _RecipeDetailBodyState extends State<_RecipeDetailBody> {
  final TextEditingController _commentController = TextEditingController();
  bool _submittingComment = false;
  bool _showRecipeVideo = false;
  late int _selectedServings;
  int _cookCount = 0;
  String? _replyToCommentId;
  String? _replyToAuthorName;
  final Set<String> _expandedReplies = {};

  @override
  void initState() {
    super.initState();
    _selectedServings = widget.recipe.servings;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final recipeId = widget.recipe.id;
      if (recipeId == null) return;
      final userId = context.read<AuthProvider>().userModel?.uid;
      if (userId != null) {
        context.read<RatingProvider>().loadUserRating(recipeId, userId);
        context.read<CookingLogProvider>().init(userId);
        context.read<LikeProvider>().initialize(userId);
        _loadCookCount(recipeId);
      }
      context.read<CommentProvider>().listenToComments(recipeId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCookCount(String recipeId) async {
    final count = await context
        .read<CookingLogProvider>()
        .getCookCount(recipeId);
    if (mounted) setState(() => _cookCount = count);
  }

  Future<void> _showLogCookSheet(BuildContext context, Recipe recipe) async {
    final cookingLogProvider = context.read<CookingLogProvider>();
    final achievementProvider = context.read<AchievementProvider>();
    final l10n = AppLocalizations.of(context)!;

    final result = await showModalBottomSheet<_LogCookResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LogCookSheet(initialServings: _selectedServings),
    );

    if (result == null || !mounted) return;

    try {
      await cookingLogProvider.logCook(
        recipe,
        personalRating: result.rating > 0 ? result.rating : null,
        notes: result.notes,
        servings: result.servings,
      );
      if (mounted) {
        _showSnackBar(l10n.cookLogged);
        await _loadCookCount(recipe.id!);
      }
      if (context.mounted) {
        await achievementProvider.triggerCheck(context);
      }
    } catch (_) {
      if (mounted) _showSnackBar(l10n.error);
    }
  }

  String _scaledAmount(String originalAmount, int originalServings) {
    final parsed = double.tryParse(originalAmount);
    if (parsed == null || originalServings <= 0) return originalAmount;
    final scaled = parsed * _selectedServings / originalServings;
    return scaled == scaled.roundToDouble()
        ? scaled.toInt().toString()
        : scaled.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  bool _isOwner(Recipe r) {
    final userId = context.read<AuthProvider>().userModel?.uid;
    return userId != null && userId == r.authorId;
  }

  Future<void> _deleteRecipe(BuildContext context, Recipe r) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.delete),
        content: Text('${l10n.delete} "${r.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final trendingProvider = context.read<TrendingProvider>();
      await context.read<RecipeProvider>().deleteRecipe(r.id!);
      trendingProvider.removeRecipe(r.id!);
      if (context.mounted) context.pop();
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onSendPressed(Recipe r) async {
    final ratingProvider = context.read<RatingProvider>();
    final commentProvider = context.read<CommentProvider>();
    final activityProvider = context.read<ActivityProvider>();
    final user = context.read<AuthProvider>().userModel;
    if (user == null) return;

    if (_isOwner(r)) {
      _showSnackBar(AppLocalizations.of(context)!.cannotRateOwnRecipe);
      return;
    }

    final pendingStars = ratingProvider.displayStars;
    final hasExistingRating = ratingProvider.userRating != null;
    final commentText = _commentController.text.trim();

    final myEntry = commentProvider.comments
        .where((c) => c.userId == user.uid)
        .firstOrNull;
    final hasTextComment = myEntry != null && myEntry.text.isNotEmpty;

    if (pendingStars == 0 && commentText.isEmpty) {
      _showSnackBar(AppLocalizations.of(context)!.pleaseSelectStarsOrComment);
      return;
    }

    if (pendingStars > 0 && hasExistingRating) {
      _showSnackBar(AppLocalizations.of(context)!.deleteRatingFirst);
      return;
    }

    if (commentText.isNotEmpty && hasTextComment) {
      _showSnackBar(AppLocalizations.of(context)!.deleteCommentFirst);
      return;
    }

    setState(() => _submittingComment = true);
    try {
      if (pendingStars > 0 && !hasExistingRating) {
        await ratingProvider.submitRating(
          recipeId: r.id!,
          userId: user.uid,
        );
      }

      final commentStars = ratingProvider.userRating?.stars ?? pendingStars;

      if (myEntry == null) {
        await commentProvider.addComment(Comment(
          recipeId: r.id!,
          userId: user.uid,
          authorName: user.fullName,
          text: commentText,
          stars: commentStars,
          createdAt: DateTime.now(),
        ));
      } else if (commentText.isNotEmpty && myEntry.text.isEmpty) {
        await commentProvider.updateCommentText(
          commentId: myEntry.id!,
          recipeId: r.id!,
          newText: commentText,
          newStars: commentStars,
        );
      }
      _commentController.clear();

      // Create a single activity notification for comment+rating
      final hasNewRating = pendingStars > 0 && !hasExistingRating;
      if (commentText.isNotEmpty && hasNewRating) {
        // Combined: comment + rating → single comment activity with stars in message
        await activityProvider.createCommentActivity(
          recipeAuthorId: r.authorId,
          actorId: user.uid,
          actorName: user.fullName,
          actorAvatar: user.photoUrl,
          recipeId: r.id!,
          recipeName: r.title,
          recipeImageUrl: r.imageUrl,
          commentText: commentText,
          stars: pendingStars,
        );
      } else if (commentText.isNotEmpty) {
        await activityProvider.createCommentActivity(
          recipeAuthorId: r.authorId,
          actorId: user.uid,
          actorName: user.fullName,
          actorAvatar: user.photoUrl,
          recipeId: r.id!,
          recipeName: r.title,
          recipeImageUrl: r.imageUrl,
          commentText: commentText,
        );
      } else if (hasNewRating) {
        await activityProvider.createRatingActivity(
          recipeAuthorId: r.authorId,
          actorId: user.uid,
          actorName: user.fullName,
          actorAvatar: user.photoUrl,
          recipeId: r.id!,
          recipeName: r.title,
          recipeImageUrl: r.imageUrl,
          stars: pendingStars,
        );
      }

      // Show success feedback
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        if (commentText.isNotEmpty) {
          _showSnackBar(l10n.commentSubmitted);
        } else if (hasNewRating) {
          _showSnackBar(l10n.ratingSubmitted);
        }
      }
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  Future<void> _deleteReview(String commentId, String recipeId) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.deleteComment),
        content: Text(l10n.ratingCommentDeleteWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final userId = context.read<AuthProvider>().userModel?.uid;
      final commentProvider = context.read<CommentProvider>();
      final ratingProvider = context.read<RatingProvider>();
      await commentProvider.deleteComment(
        commentId: commentId,
        recipeId: recipeId,
      );
      if (userId != null && mounted) {
        await ratingProvider.deleteRating(
          recipeId: recipeId,
          userId: userId,
        );
      }
    }
  }

  Future<void> _shareRecipe(Recipe r) async {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await Share.share(
        'https://se380-food-tracker.web.app/recipe/${r.id}',
        sharePositionOrigin: box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : null,
      );
    } catch (_) {}
  }

  void _showAddToShoppingListSheet(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ShoppingListProvider>();
    final userId = context.read<AuthProvider>().userModel?.uid;
    if (userId != null) provider.init(userId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: provider,
          builder: (_, _) {
            final lists = provider.lists;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.addToShoppingList,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                      title: Text(l10n.createNewList),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _createAndAddToList(context, recipe);
                      },
                    ),
                    if (lists.isNotEmpty) const Divider(),
                    ...lists.map((list) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.list_alt,
                                color: AppTheme.primaryColor),
                          ),
                          title: Text(list.name),
                          subtitle: Text(
                            '${list.items.length} ${l10n.ingredients.toLowerCase()}',
                          ),
                          onTap: () async {
                            Navigator.pop(ctx);
                            await _addIngredientsToList(
                                context, list.id!, list.name, recipe);
                          },
                        )),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddToCollectionSheet(BuildContext context, Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    final collectionProvider = context.read<CollectionProvider>();
    final userId = context.read<AuthProvider>().userModel?.uid;
    if (userId != null) collectionProvider.init(userId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ListenableBuilder(
          listenable: collectionProvider,
          builder: (_, _) {
            final collections = collectionProvider.collections;
            final recipeId = recipe.id;
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        l10n.addToCollection,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                      title: Text(l10n.createNewCollection),
                      onTap: () async {
                        Navigator.pop(ctx);
                        await _createCollectionAndAddRecipe(context, recipe);
                      },
                    ),
                    if (collections.isNotEmpty) const Divider(),
                    ...collections.map((collection) {
                      final contains = recipeId != null &&
                          collection.recipeIds.contains(recipeId);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            contains ? Icons.folder : Icons.folder_outlined,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        title: Text(collection.name),
                        subtitle: Text(
                          l10n.recipeCountInCollection(
                              collection.recipeIds.length),
                        ),
                        trailing: contains
                            ? const Icon(Icons.check_circle,
                                color: AppTheme.primaryColor)
                            : null,
                        onTap: () async {
                          Navigator.pop(ctx);
                          if (recipeId == null) return;
                          final messenger = ScaffoldMessenger.of(context);
                          if (contains) {
                            await collectionProvider.removeRecipe(
                                collection.id!, recipeId);
                            if (context.mounted) {
                              messenger.showSnackBar(SnackBar(
                                content: Text(
                                    l10n.removedFromCollection(collection.name)),
                              ));
                            }
                          } else {
                            await collectionProvider.addRecipe(
                                collection.id!, recipeId);
                            if (context.mounted) {
                              messenger.showSnackBar(SnackBar(
                                content: Text(
                                    l10n.addedToCollection(collection.name)),
                              ));
                            }
                          }
                        },
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _createCollectionAndAddRecipe(
      BuildContext context, Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final collectionProvider = context.read<CollectionProvider>();
    final achievementProvider = context.read<AchievementProvider>();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.newCollection),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.collectionName),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (name != null && name.isNotEmpty && mounted) {
      try {
        final collectionId = await collectionProvider.createCollection(name);
        if (recipe.id != null && collectionId.isNotEmpty) {
          await collectionProvider.addRecipe(collectionId, recipe.id!);
        }
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.addedToCollection(name))),
          );
        }
        if (context.mounted) {
          await achievementProvider.triggerCheck(context);
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.error)));
        }
      }
    }
  }

  Future<void> _createAndAddToList(BuildContext context, Recipe recipe) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = context.read<AuthProvider>().userModel?.uid;
    final messenger = ScaffoldMessenger.of(context);
    final shoppingProvider = context.read<ShoppingListProvider>();
    final achievementProvider = context.read<AchievementProvider>();
    if (userId == null) return;
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.newList),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.listName),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
    if (name != null && name.isNotEmpty && mounted) {
      try {
        final items = recipe.ingredients
            .map((ing) => ShoppingItem(
                  name: ing.name,
                  amount: _scaledAmount(ing.amount, recipe.servings),
                  unit: ing.unit,
                ))
            .toList();
        final listId = await shoppingProvider.createList(name);
        if (listId.isNotEmpty) {
          await shoppingProvider.addIngredientsToList(listId, items);
        }
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.addedToList(name))),
          );
        }
        if (context.mounted) {
          await achievementProvider.triggerCheck(context);
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.error)),
          );
        }
      }
    }
  }

  Future<void> _addIngredientsToList(
    BuildContext context,
    String listId,
    String listName,
    Recipe recipe,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<ShoppingListProvider>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final items = recipe.ingredients
          .map((ing) => ShoppingItem(
                name: ing.name,
                amount: _scaledAmount(ing.amount, recipe.servings),
                unit: ing.unit,
              ))
          .toList();
      await provider.addIngredientsToList(listId, items);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.addedToList(listName))),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final liveRecipe = context
        .watch<RecipeProvider>()
        .allRecipes
        .firstWhere((r) => r.id == widget.recipe.id, orElse: () => widget.recipe);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, liveRecipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleSection(context, l10n, theme, liveRecipe),
                  const SizedBox(height: 12),
                  _buildLikeReportRow(context, l10n, liveRecipe),
                  const SizedBox(height: 16),
                  _buildTimeRow(context, l10n, theme, liveRecipe),
                  if (_hasNutrition(liveRecipe)) ...[
                    const SizedBox(height: 16),
                    _buildNutritionCard(context, l10n, theme, liveRecipe),
                  ],
                  const SizedBox(height: 16),
                  ServingSizeSelector(
                    currentServings: _selectedServings,
                    onChanged: (v) => setState(() => _selectedServings = v),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.ingredients,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  IngredientListView(
                    ingredients: _displayIngredients(liveRecipe),
                    scaleFactor: liveRecipe.servings > 0
                        ? _selectedServings / liveRecipe.servings
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.steps,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StepOverviewList(steps: _displaySteps(liveRecipe)),
                  const SizedBox(height: 24),
                  GradientButton(
                    text: l10n.startCooking,
                    icon: Icons.restaurant,
                    onPressed: () {
                      context.push('/cooking/${liveRecipe.id}', extra: liveRecipe);
                    },
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: l10n.iCookedThis,
                    icon: Icons.outdoor_grill,
                    onPressed: context.read<AuthProvider>().isAuthenticated
                        ? () => _showLogCookSheet(context, liveRecipe)
                        : null,
                    trailing: _cookCount > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '×$_cookCount',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: l10n.addToShoppingList,
                    icon: Icons.shopping_cart_outlined,
                    onPressed: () => _showAddToShoppingListSheet(context, liveRecipe),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    text: l10n.addToCollection,
                    icon: Icons.folder_outlined,
                    onPressed: () => _showAddToCollectionSheet(context, liveRecipe),
                  ),
                  const SizedBox(height: 32),
                  _buildRatingsSection(context, l10n, theme, liveRecipe),
                  const SizedBox(height: 24),
                  _buildCommentsSection(context, l10n, theme, liveRecipe),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Ingredient> _displayIngredients(Recipe r) => r.ingredients;

  List<RecipeStep> _displaySteps(Recipe r) => r.steps;

  Widget _buildGlassCircleButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onPressed,
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.glassWhite.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Recipe r) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      actions: [
        if (r.videoUrl != null)
          _buildGlassCircleButton(
            icon: _showRecipeVideo
                ? Icons.photo_outlined
                : Icons.play_circle_outline,
            iconColor: Colors.white,
            onPressed: () =>
                setState(() => _showRecipeVideo = !_showRecipeVideo),
          ),
        Builder(builder: (ctx) {
          final favProvider = ctx.watch<FavoriteProvider>();
          final isFav = r.id != null && favProvider.isFavorite(r.id!);
          return _buildGlassCircleButton(
            icon: isFav ? Icons.favorite : Icons.favorite_border,
            iconColor: isFav ? AppTheme.errorColor : Colors.white,
            onPressed: () {
              if (r.id != null) favProvider.toggleFavorite(r.id!);
            },
          );
        }),
        _buildGlassCircleButton(
          icon: Icons.share_outlined,
          iconColor: Colors.white,
          onPressed: () => _shareRecipe(r),
        ),
        if (_isOwner(r)) ...[
          _buildGlassCircleButton(
            icon: Icons.edit_outlined,
            iconColor: Colors.white,
            onPressed: () =>
                context.push('/edit-recipe/${r.id}', extra: r),
          ),
          _buildGlassCircleButton(
            icon: Icons.delete_outline,
            iconColor: Colors.white,
            onPressed: () => _deleteRecipe(context, r),
          ),
        ],
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildPhotoArea(r),
            // Gradient overlay — IgnorePointer so carousel gestures pass through
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppTheme.neutralLight,
      child: const Center(
        child: Icon(Icons.restaurant_menu, size: 80, color: AppTheme.textTertiary),
      ),
    );
  }

  Widget _buildPhotoArea(Recipe r) {
    if (_showRecipeVideo && r.videoUrl != null) {
      return VideoPlayerWidget(videoUrl: r.videoUrl!);
    }
    final allPhotos = [
      if (r.imageUrl != null) r.imageUrl!,
      ...r.photos,
    ];
    if (allPhotos.isEmpty) return _buildPlaceholderImage();
    return PhotoCarousel(photos: allPhotos, height: 320);
  }

  Widget _buildTitleSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          r.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                final currentUserId =
                    context.read<AuthProvider>().userModel?.uid;
                if (r.authorId == currentUserId) {
                  context.go('/profile');
                } else {
                  context.push('/user/${r.authorId}', extra: r.authorName);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        AppTheme.primaryColor.withValues(alpha: 0.15),
                    child: Text(
                      r.authorName.isNotEmpty
                          ? r.authorName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    r.authorName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Chip(
              label: Text(localizeCategory(r.category, l10n)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeRow(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
  ) {
    return Row(
      children: [
        _buildTimeItem(
          icon: Icons.hourglass_top,
          label: l10n.prepTime,
          value: '${r.prepTimeMinutes} min',
          theme: theme,
        ),
        const SizedBox(width: 24),
        _buildTimeItem(
          icon: Icons.local_fire_department,
          label: l10n.cookTime,
          value: '${r.cookTimeMinutes} min',
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildTimeItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _hasNutrition(Recipe r) =>
      r.caloriesPerServing != null ||
      r.proteinGrams != null ||
      r.carbsGrams != null ||
      r.fatGrams != null;

  Widget _buildNutritionCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
  ) {
    final scale = r.servings > 0 ? _selectedServings / r.servings : 1.0;

    String scaleVal(num val) {
      final scaled = val * scale;
      return scaled == scaled.roundToDouble()
          ? scaled.toInt().toString()
          : scaled.toStringAsFixed(1);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (r.caloriesPerServing != null)
              _buildNutritionItem(
                label: l10n.calories,
                value: scaleVal(r.caloriesPerServing!),
                unit: 'kcal',
                theme: theme,
              ),
            if (r.proteinGrams != null)
              _buildNutritionItem(
                label: l10n.protein,
                value: scaleVal(r.proteinGrams!),
                unit: 'g',
                theme: theme,
              ),
            if (r.carbsGrams != null)
              _buildNutritionItem(
                label: l10n.carbs,
                value: scaleVal(r.carbsGrams!),
                unit: 'g',
                theme: theme,
              ),
            if (r.fatGrams != null)
              _buildNutritionItem(
                label: l10n.fat,
                value: scaleVal(r.fatGrams!),
                unit: 'g',
                theme: theme,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem({
    required String label,
    required String value,
    required String unit,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }


  Widget _buildLikeReportRow(
    BuildContext context,
    AppLocalizations l10n,
    Recipe r,
  ) {
    final likeProvider = context.watch<LikeProvider>();
    final userId = context.read<AuthProvider>().userModel?.uid;
    final isLiked = r.id != null && likeProvider.isLiked(r.id!);
    final isOwner = _isOwner(r);

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: userId == null || r.id == null
              ? null
              : () => likeProvider.toggleLike(r.id!, userId),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: isLiked ? AppTheme.primaryColor : AppTheme.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.likes(r.likeCount),
                  style: TextStyle(
                    fontSize: 13,
                    color: isLiked ? AppTheme.primaryColor : AppTheme.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        if (!isOwner && userId != null)
          IconButton(
            icon: const Icon(Icons.flag_outlined, size: 20),
            color: AppTheme.textTertiary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: l10n.reportRecipe,
            onPressed: () => _showReportDialog(context, l10n, r),
          ),
      ],
    );
  }

  Future<void> _showReportDialog(
    BuildContext context,
    AppLocalizations l10n,
    Recipe r,
  ) async {
    final userModel = context.read<AuthProvider>().userModel;
    final userId = userModel?.uid;
    if (userId == null) return;

    String? selectedReason;
    final descController = TextEditingController();
    final reasons = [
      l10n.reportReasonSpam,
      l10n.reportReasonInappropriate,
      l10n.reportReasonHarassment,
      l10n.reportReasonMisinformation,
      l10n.reportReasonOther,
    ];

    final result = await showDialog<Map<String, String?>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(l10n.reportRecipe),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...reasons.map((reason) => InkWell(
                      onTap: () =>
                          setDialogState(() => selectedReason = reason),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Icon(
                              selectedReason == reason
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 20,
                              color: selectedReason == reason
                                  ? AppTheme.primaryColor
                                  : AppTheme.textTertiary,
                            ),
                            const SizedBox(width: 12),
                            Text(reason,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: l10n.reportDescriptionHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.all(10),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: selectedReason == null
                  ? null
                  : () => Navigator.pop(ctx, {
                        'reason': selectedReason,
                        'description': descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                      }),
              child: Text(l10n.report),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;

    try {
      await ReportService().submitReport(Report(
        reporterId: userId,
        reporterName: userModel?.fullName,
        targetType: 'recipe',
        targetId: r.id!,
        targetAuthorId: r.authorId,
        targetName: r.title,
        reason: result['reason']!,
        description: result['description'],
        createdAt: DateTime.now(),
      ));
      if (mounted) _showSnackBar(l10n.reportSubmitted);
    } catch (_) {
      if (mounted) _showSnackBar(l10n.error);
    }
  }

  Future<void> _onSendReply(Recipe r) async {
    final commentProvider = context.read<CommentProvider>();
    final user = context.read<AuthProvider>().userModel;
    if (user == null || _replyToCommentId == null) return;

    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final parentId = _replyToCommentId!;
    setState(() => _submittingComment = true);
    try {
      await commentProvider.addComment(Comment(
        recipeId: r.id!,
        userId: user.uid,
        authorName: user.fullName,
        text: text,
        createdAt: DateTime.now(),
        parentCommentId: parentId,
      ));
      _commentController.clear();
      setState(() {
        _expandedReplies.add(parentId);
        _replyToCommentId = null;
        _replyToAuthorName = null;
      });
    } catch (_) {
      if (mounted) _showSnackBar(AppLocalizations.of(context)!.error);
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  Widget _buildRatingsSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
  ) {
    final ratingProvider = context.watch<RatingProvider>();
    final userId = context.read<AuthProvider>().userModel?.uid;
    final isOwner = _isOwner(r);
    final hasExistingRating = ratingProvider.userRating != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.ratingsAndComments,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (r.ratingCount > 0) ...[
              const Icon(Icons.star, size: 18, color: AppTheme.starColor),
              const SizedBox(width: 4),
              Text(
                r.averageRating.toStringAsFixed(1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                l10n.ratingCount(r.ratingCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
        ),
        if (userId != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.yourRating,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          _StarRatingWidget(
            currentStars: ratingProvider.displayStars,
            onRate: (stars) async {
              if (isOwner) {
                _showSnackBar(l10n.cannotRateOwnRecipeShort);
                return;
              }
              if (hasExistingRating) {
                _showSnackBar(l10n.deleteReviewToRerate);
                return;
              }
              context.read<RatingProvider>().selectStars(stars);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCommentsSection(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
  ) {
    final commentProvider = context.watch<CommentProvider>();
    final blockedIds = context.watch<BlockProvider>().blockedUserIds;
    final topLevel = commentProvider.topLevelComments
        .where((c) => !blockedIds.contains(c.userId))
        .toList();
    final userId = context.read<AuthProvider>().userModel?.uid;
    final hasMyTextComment = userId != null &&
        topLevel.any((c) => c.userId == userId && c.text.isNotEmpty);
    final isReplying = _replyToCommentId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userId != null) ...[
          if (isReplying)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply,
                      size: 14, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  Text(
                    l10n.replyingTo(_replyToAuthorName ?? ''),
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.primaryColor),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _replyToCommentId = null;
                      _replyToAuthorName = null;
                      _commentController.clear();
                    }),
                    child: Text(
                      l10n.cancelReply,
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.errorColor),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: isReplying
                        ? l10n.reply
                        : (hasMyTextComment
                            ? l10n.deleteCommentToWriteNew
                            : l10n.writeComment),
                    hintStyle: TextStyle(
                      color: hasMyTextComment && !isReplying
                          ? AppTheme.starColor
                          : AppTheme.textTertiary,
                      fontSize: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              _submittingComment
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton.filled(
                      onPressed: () => isReplying
                          ? _onSendReply(r)
                          : _onSendPressed(r),
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (topLevel.isEmpty)
          Center(
            child: Text(
              l10n.noComments,
              style: const TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14,
              ),
            ),
          )
        else
          ...topLevel.map((c) => _buildCommentCard(
              context, l10n, theme, r, c, userId, commentProvider)),
      ],
    );
  }

  Widget _buildCommentCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Recipe r,
    Comment c,
    String? userId,
    CommentProvider commentProvider,
  ) {
    final isMyComment = c.userId == userId;
    final blockedIds = context.read<BlockProvider>().blockedUserIds;
    final replies = commentProvider.repliesFor(c.id ?? '')
        .where((r) => !blockedIds.contains(r.userId))
        .toList();
    final replyCount = replies.length;
    final isExpanded = _expandedReplies.contains(c.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.neutralSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.neutralLight.withValues(alpha: 0.5),
            ),
            boxShadow: [AppTheme.warmShadowLight()],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                    child: Text(
                      c.authorName.isNotEmpty
                          ? c.authorName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.authorName,
                          style:
                              const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (c.stars > 0)
                          Row(
                            children: List.generate(
                                5,
                                (i) => Icon(
                                      i < c.stars
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 13,
                                      color: AppTheme.starColor,
                                    )),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(c.createdAt),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  if (isMyComment) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _deleteReview(c.id!, r.id!),
                      child: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ],
              ),
              if (c.text.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(c.text, style: const TextStyle(fontSize: 14)),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  if (userId != null)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _replyToCommentId = c.id;
                        _replyToAuthorName = c.authorName;
                        _commentController.clear();
                      }),
                      icon: const Icon(Icons.reply, size: 15),
                      label: Text(l10n.reply),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 12),
                        minimumSize: Size.zero,
                      ),
                    ),
                  if (replyCount > 0)
                    TextButton(
                      onPressed: () => setState(() {
                        if (isExpanded) {
                          _expandedReplies.remove(c.id);
                        } else {
                          _expandedReplies.add(c.id!);
                        }
                      }),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(fontSize: 12),
                        minimumSize: Size.zero,
                      ),
                      child: Text(isExpanded
                          ? l10n.hideReplies
                          : l10n.viewReplies(replyCount)),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Column(
              children: replies
                  .map((reply) =>
                      _buildReplyCard(context, theme, reply, userId))
                  .toList(),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReplyCard(
    BuildContext context,
    ThemeData theme,
    Comment reply,
    String? userId,
  ) {
    final isMyReply = reply.userId == userId;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.neutralSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.neutralLight.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor:
                    theme.colorScheme.secondary.withValues(alpha: 0.15),
                child: Text(
                  reply.authorName.isNotEmpty
                      ? reply.authorName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  reply.authorName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
              Text(
                _formatDate(reply.createdAt),
                style: const TextStyle(
                    fontSize: 10, color: AppTheme.textTertiary),
              ),
              if (isMyReply) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () async {
                    final commentProvider =
                        context.read<CommentProvider>();
                    await commentProvider.deleteComment(
                      commentId: reply.id!,
                      recipeId: reply.recipeId,
                    );
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    size: 15,
                    color: AppTheme.errorColor,
                  ),
                ),
              ],
            ],
          ),
          if (reply.text.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(reply.text, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StarRatingWidget extends StatelessWidget {
  final int currentStars;
  final Future<void> Function(int stars) onRate;

  const _StarRatingWidget({required this.currentStars, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final star = i + 1;
        return GestureDetector(
          onTap: () => onRate(star),
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Icon(
              star <= currentStars ? Icons.star : Icons.star_border,
              color: AppTheme.starColor,
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}

class _LogCookResult {
  final int rating;
  final String? notes;
  final int servings;
  const _LogCookResult({required this.rating, required this.notes, required this.servings});
}

class _LogCookSheet extends StatefulWidget {
  final int initialServings;
  const _LogCookSheet({required this.initialServings});

  @override
  State<_LogCookSheet> createState() => _LogCookSheetState();
}

class _LogCookSheetState extends State<_LogCookSheet> {
  late int _servings;
  int _rating = 0;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _servings = widget.initialServings;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.neutralLightOf(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.iCookedThis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        i < _rating ? Icons.star : Icons.star_border,
                        size: 32,
                        color: AppTheme.starColor,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    l10n.serves(_servings),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: _servings > 1 ? () => setState(() => _servings--) : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _servings < 20 ? () => setState(() => _servings++) : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: l10n.personalNotes,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    final notes = _notesController.text.trim();
                    Navigator.pop(
                      context,
                      _LogCookResult(
                        rating: _rating,
                        notes: notes.isEmpty ? null : notes,
                        servings: _servings,
                      ),
                    );
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
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/recipe.dart';
import '../models/food_item.dart';
import '../services/recipe_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/shell/shell_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/feed/feed_screen.dart';
import '../screens/my_recipes/my_recipes_screen.dart';
import '../screens/daily_tracker/daily_tracker_screen.dart';
import '../screens/food_items/food_item_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/follow_list_screen.dart';
import '../screens/profile/public_profile_screen.dart';
import '../screens/add_recipe/add_recipe_screen.dart';
import '../screens/edit_recipe/edit_recipe_screen.dart';
import '../screens/recipe_detail/recipe_detail_screen.dart';
import '../screens/cooking_mode/cooking_mode_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/food_items/add_food_item_screen.dart';
import '../screens/food_items/food_item_detail_screen.dart';
import '../screens/daily_tracker/add_meal_entry_screen.dart';
import '../screens/daily_tracker/nutrition_goals_screen.dart';
import '../screens/shopping_list/shopping_lists_screen.dart';
import '../screens/shopping_list/shopping_list_detail_screen.dart';
import '../screens/collections/collection_list_screen.dart';
import '../screens/collections/collection_detail_screen.dart';
import '../screens/meal_planner/meal_planner_screen.dart';

import '../screens/profile/blocked_users_screen.dart';
import '../screens/profile/notification_settings_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/activity/activity_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_recipes_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_announcements_screen.dart';
import '../screens/admin/admin_appeals_screen.dart';
import '../screens/admin/admin_audit_log_screen.dart';
import '../screens/admin/admin_reports_screen.dart';
import '../screens/auth/banned_screen.dart';
import '../screens/cooking_history/cooking_history_screen.dart';
import '../screens/trending/trending_recipes_screen.dart';
import '../screens/achievements/achievements_screen.dart';
import '../models/meal_entry.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Page not found'),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Bottom navigation shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ShellScreen(navigationShell: navigationShell),
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // Tab 1: Feed
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/feed',
              builder: (context, state) => const FeedScreen(),
            ),
          ],
        ),
        // Tab 2: Daily Tracker
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/daily-tracker',
              builder: (context, state) => const DailyTrackerScreen(),
            ),
          ],
        ),
        // Tab 3: Materials
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/materials',
              builder: (context, state) => const FoodItemListScreen(),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),

    // Sub-screens that push on top of the shell
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add-recipe',
      builder: (context, state) {
        final initial = state.extra as Recipe?;
        return AddRecipeScreen(initialRecipe: initial);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/edit-recipe/:id',
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe == null) {
          return const Scaffold(body: Center(child: Text('Recipe not found')));
        }
        return EditRecipeScreen(recipe: recipe);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/recipe/:id',
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe != null) {
          return RecipeDetailScreen(recipe: recipe);
        }
        final recipeId = state.pathParameters['id']!;
        return _RecipeLoaderScreen(recipeId: recipeId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add-food-item',
      builder: (context, state) => const AddFoodItemScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/edit-food-item',
      builder: (context, state) {
        final foodItem = state.extra as FoodItem?;
        return AddFoodItemScreen(editItem: foodItem);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/food-item/:id',
      builder: (context, state) {
        final foodItem = state.extra as FoodItem?;
        if (foodItem == null) {
          return const Scaffold(
              body: Center(child: Text('Food item not found')));
        }
        return FoodItemDetailScreen(foodItem: foodItem);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add-meal-entry',
      builder: (context, state) {
        final mealType = state.extra as MealType? ?? MealType.snack;
        return AddMealEntryScreen(mealType: mealType);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/nutrition-goals',
      builder: (context, state) => const NutritionGoalsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/my-recipes',
      builder: (context, state) {
        final userId = state.extra as String?;
        return MyRecipesScreen(userId: userId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/follow-list/:id',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        final initialTab = (state.extra as int?) ?? 0;
        return FollowListScreen(userId: userId, initialTab: initialTab);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/user/:id',
      builder: (context, state) {
        final userId = state.pathParameters['id']!;
        final initialName = state.extra as String? ?? '';
        return PublicProfileScreen(
          userId: userId,
          initialName: initialName,
        );
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/shopping-lists',
      builder: (context, state) => const ShoppingListsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/shopping-list/:id',
      builder: (context, state) {
        final listId = state.pathParameters['id']!;
        return ShoppingListDetailScreen(listId: listId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/collections',
      builder: (context, state) => const CollectionListScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/collection/:id',
      builder: (context, state) {
        final collectionId = state.pathParameters['id']!;
        return CollectionDetailScreen(collectionId: collectionId);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/cooking/:id',
      builder: (context, state) {
        final recipe = state.extra as Recipe?;
        if (recipe == null) {
          return const Scaffold(
              body: Center(child: Text('Recipe not found')));
        }
        return CookingModeScreen(recipe: recipe);
      },
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/meal-planner',
      builder: (context, state) => const MealPlannerScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/blocked-users',
      builder: (context, state) => const BlockedUsersScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/announcements',
      builder: (context, state) => const ActivityScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/users',
      builder: (context, state) => const AdminUsersScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/recipes',
      builder: (context, state) => const AdminRecipesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/categories',
      builder: (context, state) => const AdminCategoriesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/announcements',
      builder: (context, state) => const AdminAnnouncementsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/appeals',
      builder: (context, state) => const AdminAppealsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/audit-log',
      builder: (context, state) => const AdminAuditLogScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/admin/reports',
      builder: (context, state) => const AdminReportsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/banned',
      builder: (context, state) => const BannedScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/cooking-history',
      builder: (context, state) => const CookingHistoryScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/trending',
      builder: (context, state) => const TrendingRecipesScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/achievements',
      builder: (context, state) => const AchievementsScreen(),
    ),
  ],
);

class _RecipeLoaderScreen extends StatefulWidget {
  final String recipeId;
  const _RecipeLoaderScreen({required this.recipeId});

  @override
  State<_RecipeLoaderScreen> createState() => _RecipeLoaderScreenState();
}

class _RecipeLoaderScreenState extends State<_RecipeLoaderScreen> {
  late Future<Recipe?> _future;

  @override
  void initState() {
    super.initState();
    _future = RecipeService().getRecipe(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Recipe?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final recipe = snapshot.data;
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Recipe not found')),
          );
        }
        return RecipeDetailScreen(recipe: recipe);
      },
    );
  }
}

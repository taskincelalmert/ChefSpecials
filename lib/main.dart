import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/recipe_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/food_item_provider.dart';
import 'providers/daily_tracker_provider.dart';
import 'providers/follow_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/shopping_list_provider.dart';
import 'providers/collection_provider.dart';
import 'providers/meal_plan_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/activity_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/cooking_log_provider.dart';
import 'providers/trending_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/like_provider.dart';
import 'providers/block_provider.dart';
import 'providers/unit_preference_provider.dart';
import 'app.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => FoodItemProvider()),
        ChangeNotifierProvider(create: (_) => DailyTrackerProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FollowProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingListProvider()),
        ChangeNotifierProvider(create: (_) => CollectionProvider()),
        ChangeNotifierProvider(create: (_) => MealPlanProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => CookingLogProvider()),
        ChangeNotifierProvider(create: (_) => TrendingProvider()),
        ChangeNotifierProvider(create: (_) => AchievementProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => BlockProvider()),
        ChangeNotifierProvider(create: (_) => UnitPreferenceProvider()),
      ],
      child: const ChefSpecialsApp(),
    ),
  );
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'ChefSpecials'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get haveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orLabel;

  /// No description provided for @linkAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account already exists'**
  String get linkAccountTitle;

  /// No description provided for @linkAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered with a password. Enter it to connect Google sign-in to your account.'**
  String get linkAccountMessage;

  /// No description provided for @linkAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get linkAccountButton;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get loginRequired;

  /// No description provided for @loginRequiredFeedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see recipes from people you follow.'**
  String get loginRequiredFeedMessage;

  /// No description provided for @loginRequiredProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view and manage your profile.'**
  String get loginRequiredProfileMessage;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @addRecipe.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipe;

  /// No description provided for @recipeName.
  ///
  /// In en, this message translates to:
  /// **'Recipe Name'**
  String get recipeName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// No description provided for @prepTime.
  ///
  /// In en, this message translates to:
  /// **'Prep Time'**
  String get prepTime;

  /// No description provided for @cookTime.
  ///
  /// In en, this message translates to:
  /// **'Cook Time'**
  String get cookTime;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @startCooking.
  ///
  /// In en, this message translates to:
  /// **'Start Cooking'**
  String get startCooking;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @stepCompleted.
  ///
  /// In en, this message translates to:
  /// **'Step completed'**
  String get stepCompleted;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @noRecipes.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet'**
  String get noRecipes;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchHint;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @myRecipes.
  ///
  /// In en, this message translates to:
  /// **'My Recipes'**
  String get myRecipes;

  /// No description provided for @dailyTracker.
  ///
  /// In en, this message translates to:
  /// **'Daily Tracker'**
  String get dailyTracker;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// No description provided for @addRecipeToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipeToMeal;

  /// No description provided for @nutritionGoals.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get nutritionGoals;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @calorieTarget.
  ///
  /// In en, this message translates to:
  /// **'Calorie Target'**
  String get calorieTarget;

  /// No description provided for @proteinTarget.
  ///
  /// In en, this message translates to:
  /// **'Protein Target'**
  String get proteinTarget;

  /// No description provided for @carbsTarget.
  ///
  /// In en, this message translates to:
  /// **'Carbs Target'**
  String get carbsTarget;

  /// No description provided for @fatTarget.
  ///
  /// In en, this message translates to:
  /// **'Fat Target'**
  String get fatTarget;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @gram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get gram;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'mL'**
  String get ml;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @selectFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Select Food Item'**
  String get selectFoodItem;

  /// No description provided for @selectRecipe.
  ///
  /// In en, this message translates to:
  /// **'Select Recipe'**
  String get selectRecipe;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @noMealsYet.
  ///
  /// In en, this message translates to:
  /// **'No meals logged yet'**
  String get noMealsYet;

  /// No description provided for @addToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal'**
  String get addToMeal;

  /// No description provided for @goalsSaved.
  ///
  /// In en, this message translates to:
  /// **'Goals saved'**
  String get goalsSaved;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @exceeded.
  ///
  /// In en, this message translates to:
  /// **'Exceeded'**
  String get exceeded;

  /// No description provided for @ofLabel.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofLabel;

  /// No description provided for @dessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get dessert;

  /// No description provided for @drink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drink;

  /// No description provided for @salad.
  ///
  /// In en, this message translates to:
  /// **'Salad'**
  String get salad;

  /// No description provided for @soup.
  ///
  /// In en, this message translates to:
  /// **'Soup'**
  String get soup;

  /// No description provided for @searchRecipeOrIngredient.
  ///
  /// In en, this message translates to:
  /// **'Search recipe or ingredient...'**
  String get searchRecipeOrIngredient;

  /// No description provided for @minuteShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minuteShort;

  /// No description provided for @popular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @remainingKcal.
  ///
  /// In en, this message translates to:
  /// **'Remaining kcal'**
  String get remainingKcal;

  /// No description provided for @todaysMeals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Meals'**
  String get todaysMeals;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @itemsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} items added'**
  String itemsAdded(Object count);

  /// No description provided for @notAddedYet.
  ///
  /// In en, this message translates to:
  /// **'Not added yet'**
  String get notAddedYet;

  /// No description provided for @waterTracking.
  ///
  /// In en, this message translates to:
  /// **'Water Tracking'**
  String get waterTracking;

  /// No description provided for @carbsShort.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbsShort;

  /// No description provided for @waterTarget.
  ///
  /// In en, this message translates to:
  /// **'Water Target'**
  String get waterTarget;

  /// No description provided for @recipeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String recipeCount(Object count);

  /// No description provided for @searchFoodItems.
  ///
  /// In en, this message translates to:
  /// **'Search food items...'**
  String get searchFoodItems;

  /// No description provided for @noFoodItems.
  ///
  /// In en, this message translates to:
  /// **'No food items yet'**
  String get noFoodItems;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// No description provided for @per100.
  ///
  /// In en, this message translates to:
  /// **'per 100g'**
  String get per100;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(Object count);

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @recipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get recipes;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(Object date);

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @deleteRating.
  ///
  /// In en, this message translates to:
  /// **'Delete Rating'**
  String get deleteRating;

  /// No description provided for @ratingsAndComments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get ratingsAndComments;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @noComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet. Be the first!'**
  String get noComments;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your Rating'**
  String get yourRating;

  /// No description provided for @tapToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get tapToRate;

  /// No description provided for @deleteComment.
  ///
  /// In en, this message translates to:
  /// **'Delete Comment'**
  String get deleteComment;

  /// No description provided for @deleteCommentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this comment?'**
  String get deleteCommentConfirm;

  /// No description provided for @ratingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String ratingCount(int count);

  /// No description provided for @commentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} comments'**
  String commentCount(int count);

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @feedComingSoonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See what the people you follow are cooking.'**
  String get feedComingSoonSubtitle;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get public;

  /// No description provided for @privateDescription.
  ///
  /// In en, this message translates to:
  /// **'Only you can see this recipe.'**
  String get privateDescription;

  /// No description provided for @publicDescription.
  ///
  /// In en, this message translates to:
  /// **'Everyone can see this recipe.'**
  String get publicDescription;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @noFollowing.
  ///
  /// In en, this message translates to:
  /// **'You\'re not following anyone yet'**
  String get noFollowing;

  /// No description provided for @noFollowingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore recipes and follow people to see their latest posts here.'**
  String get noFollowingSubtitle;

  /// No description provided for @noFeedRecipes.
  ///
  /// In en, this message translates to:
  /// **'No new recipes from people you follow.'**
  String get noFeedRecipes;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get usernameRequired;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShort;

  /// No description provided for @usernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get usernameTaken;

  /// No description provided for @usernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Username is available'**
  String get usernameAvailable;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @searchFeedHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes or @username...'**
  String get searchFeedHint;

  /// No description provided for @dietaryTags.
  ///
  /// In en, this message translates to:
  /// **'Dietary Tags'**
  String get dietaryTags;

  /// No description provided for @vegan.
  ///
  /// In en, this message translates to:
  /// **'Vegan'**
  String get vegan;

  /// No description provided for @vegetarian.
  ///
  /// In en, this message translates to:
  /// **'Vegetarian'**
  String get vegetarian;

  /// No description provided for @glutenFree.
  ///
  /// In en, this message translates to:
  /// **'Gluten Free'**
  String get glutenFree;

  /// No description provided for @dairyFree.
  ///
  /// In en, this message translates to:
  /// **'Dairy Free'**
  String get dairyFree;

  /// No description provided for @keto.
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get keto;

  /// No description provided for @lowCarb.
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get lowCarb;

  /// No description provided for @halal.
  ///
  /// In en, this message translates to:
  /// **'Halal'**
  String get halal;

  /// No description provided for @shoppingLists.
  ///
  /// In en, this message translates to:
  /// **'Shopping Lists'**
  String get shoppingLists;

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @addToShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Add to Shopping List'**
  String get addToShoppingList;

  /// No description provided for @newList.
  ///
  /// In en, this message translates to:
  /// **'New List'**
  String get newList;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listName;

  /// No description provided for @clearChecked.
  ///
  /// In en, this message translates to:
  /// **'Clear Checked'**
  String get clearChecked;

  /// No description provided for @noShoppingLists.
  ///
  /// In en, this message translates to:
  /// **'No shopping lists yet'**
  String get noShoppingLists;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @itemsChecked.
  ///
  /// In en, this message translates to:
  /// **'checked'**
  String get itemsChecked;

  /// No description provided for @createNewList.
  ///
  /// In en, this message translates to:
  /// **'Create New List'**
  String get createNewList;

  /// No description provided for @addedToList.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToList(String name);

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteList;

  /// No description provided for @deleteListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list?'**
  String get deleteListConfirm;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @newCollection.
  ///
  /// In en, this message translates to:
  /// **'New Collection'**
  String get newCollection;

  /// No description provided for @collectionName.
  ///
  /// In en, this message translates to:
  /// **'Collection name'**
  String get collectionName;

  /// No description provided for @collectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get collectionDescription;

  /// No description provided for @noCollections.
  ///
  /// In en, this message translates to:
  /// **'No collections yet'**
  String get noCollections;

  /// No description provided for @deleteCollection.
  ///
  /// In en, this message translates to:
  /// **'Delete Collection'**
  String get deleteCollection;

  /// No description provided for @deleteCollectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this collection?'**
  String get deleteCollectionConfirm;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to Collection'**
  String get addToCollection;

  /// No description provided for @removeFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Remove from Collection'**
  String get removeFromCollection;

  /// No description provided for @createNewCollection.
  ///
  /// In en, this message translates to:
  /// **'Create New Collection'**
  String get createNewCollection;

  /// No description provided for @addedToCollection.
  ///
  /// In en, this message translates to:
  /// **'Added to {name}'**
  String addedToCollection(String name);

  /// No description provided for @removedFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Removed from {name}'**
  String removedFromCollection(String name);

  /// No description provided for @recipeCountInCollection.
  ///
  /// In en, this message translates to:
  /// **'{count} recipes'**
  String recipeCountInCollection(int count);

  /// No description provided for @emptyCollection.
  ///
  /// In en, this message translates to:
  /// **'No recipes in this collection'**
  String get emptyCollection;

  /// No description provided for @emptyCollectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add recipes from the recipe detail screen'**
  String get emptyCollectionSubtitle;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @applyFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters ({count})'**
  String applyFiltersCount(int count);

  /// No description provided for @favoritesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on recipes to save them here'**
  String get favoritesEmptySubtitle;

  /// No description provided for @shoppingListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add ingredients from any recipe to get started'**
  String get shoppingListEmptySubtitle;

  /// No description provided for @shareRecipe.
  ///
  /// In en, this message translates to:
  /// **'Share Recipe'**
  String get shareRecipe;

  /// No description provided for @shareRecipeText.
  ///
  /// In en, this message translates to:
  /// **'Check out \"{title}\" by {author} on ChefSpecials!\n\n{ingredients}\n\nOpen in ChefSpecials:\n{link}'**
  String shareRecipeText(
    String title,
    String author,
    String ingredients,
    String link,
  );

  /// No description provided for @mealPlanner.
  ///
  /// In en, this message translates to:
  /// **'Meal Planner'**
  String get mealPlanner;

  /// No description provided for @weekOf.
  ///
  /// In en, this message translates to:
  /// **'Week of {date}'**
  String weekOf(String date);

  /// No description provided for @copyFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Copy from Last Week'**
  String get copyFromLastWeek;

  /// No description provided for @generateShoppingListFromPlan.
  ///
  /// In en, this message translates to:
  /// **'Generate Shopping List'**
  String get generateShoppingListFromPlan;

  /// No description provided for @addMealToSlot.
  ///
  /// In en, this message translates to:
  /// **'Add Meal'**
  String get addMealToSlot;

  /// No description provided for @removeMeal.
  ///
  /// In en, this message translates to:
  /// **'Remove Meal'**
  String get removeMeal;

  /// No description provided for @weeklyNutritionSummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Nutrition'**
  String get weeklyNutritionSummary;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @noMealsPlanned.
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get noMealsPlanned;

  /// No description provided for @mealPlanServings.
  ///
  /// In en, this message translates to:
  /// **'{count} servings'**
  String mealPlanServings(int count);

  /// No description provided for @mealPlanSaved.
  ///
  /// In en, this message translates to:
  /// **'Meal plan saved'**
  String get mealPlanSaved;

  /// No description provided for @copiedFromLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Copied from last week'**
  String get copiedFromLastWeek;

  /// No description provided for @noMealPlanLastWeek.
  ///
  /// In en, this message translates to:
  /// **'No meal plan found for last week'**
  String get noMealPlanLastWeek;

  /// No description provided for @copyWeek.
  ///
  /// In en, this message translates to:
  /// **'Copy this week'**
  String get copyWeek;

  /// No description provided for @pasteWeek.
  ///
  /// In en, this message translates to:
  /// **'Paste meals here'**
  String get pasteWeek;

  /// No description provided for @weekCopied.
  ///
  /// In en, this message translates to:
  /// **'Week meals copied'**
  String get weekCopied;

  /// No description provided for @weekPasted.
  ///
  /// In en, this message translates to:
  /// **'Meals pasted to this week'**
  String get weekPasted;

  /// No description provided for @noMealsToCopy.
  ///
  /// In en, this message translates to:
  /// **'No meals to copy this week'**
  String get noMealsToCopy;

  /// No description provided for @noCopiedMeals.
  ///
  /// In en, this message translates to:
  /// **'Copy a week first'**
  String get noCopiedMeals;

  /// No description provided for @shoppingListCreated.
  ///
  /// In en, this message translates to:
  /// **'Shopping list created'**
  String get shoppingListCreated;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @averageDailyIntake.
  ///
  /// In en, this message translates to:
  /// **'Average Daily Intake'**
  String get averageDailyIntake;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'{count} day streak'**
  String currentStreak(int count);

  /// No description provided for @macroDistribution.
  ///
  /// In en, this message translates to:
  /// **'Macro Distribution'**
  String get macroDistribution;

  /// No description provided for @exportAsImage.
  ///
  /// In en, this message translates to:
  /// **'Export as Image'**
  String get exportAsImage;

  /// No description provided for @noDataForPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataForPeriod;

  /// No description provided for @avgCalories.
  ///
  /// In en, this message translates to:
  /// **'Avg Calories'**
  String get avgCalories;

  /// No description provided for @avgProtein.
  ///
  /// In en, this message translates to:
  /// **'Avg Protein'**
  String get avgProtein;

  /// No description provided for @avgCarbs.
  ///
  /// In en, this message translates to:
  /// **'Avg Carbs'**
  String get avgCarbs;

  /// No description provided for @avgFat.
  ///
  /// In en, this message translates to:
  /// **'Avg Fat'**
  String get avgFat;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn on to receive meal reminders and social alerts. You can fine-tune what you get below.'**
  String get pushNotificationsDescription;

  /// No description provided for @mealReminders.
  ///
  /// In en, this message translates to:
  /// **'Meal Reminders'**
  String get mealReminders;

  /// No description provided for @socialAlerts.
  ///
  /// In en, this message translates to:
  /// **'Social Alerts'**
  String get socialAlerts;

  /// No description provided for @breakfastReminder.
  ///
  /// In en, this message translates to:
  /// **'Breakfast Reminder'**
  String get breakfastReminder;

  /// No description provided for @lunchReminder.
  ///
  /// In en, this message translates to:
  /// **'Lunch Reminder'**
  String get lunchReminder;

  /// No description provided for @dinnerReminder.
  ///
  /// In en, this message translates to:
  /// **'Dinner Reminder'**
  String get dinnerReminder;

  /// No description provided for @newRecipeAlerts.
  ///
  /// In en, this message translates to:
  /// **'New Recipes from Followed Users'**
  String get newRecipeAlerts;

  /// No description provided for @commentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Comments on My Recipes'**
  String get commentAlerts;

  /// No description provided for @followerAlerts.
  ///
  /// In en, this message translates to:
  /// **'New Followers'**
  String get followerAlerts;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications are disabled'**
  String get notificationsDisabled;

  /// No description provided for @notificationsDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications in your phone settings to receive meal reminders and alerts.'**
  String get notificationsDisabledDescription;

  /// No description provided for @announcements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcements;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All Read'**
  String get markAllRead;

  /// No description provided for @noAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get noAnnouncements;

  /// No description provided for @activityFollow.
  ///
  /// In en, this message translates to:
  /// **'{name} started following you'**
  String activityFollow(String name);

  /// No description provided for @activityComment.
  ///
  /// In en, this message translates to:
  /// **'{name} commented on {recipe}'**
  String activityComment(String name, String recipe);

  /// No description provided for @activityRating.
  ///
  /// In en, this message translates to:
  /// **'{name} rated {recipe}'**
  String activityRating(String name, String recipe);

  /// No description provided for @activityNewRecipe.
  ///
  /// In en, this message translates to:
  /// **'{name} posted {recipe}'**
  String activityNewRecipe(String name, String recipe);

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @timeForMeal.
  ///
  /// In en, this message translates to:
  /// **'Time for {meal}!'**
  String timeForMeal(String meal);

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @recipeModeration.
  ///
  /// In en, this message translates to:
  /// **'Recipe Moderation'**
  String get recipeModeration;

  /// No description provided for @categoryManagement.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagement;

  /// No description provided for @adminAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get adminAnnouncements;

  /// No description provided for @banAppeals.
  ///
  /// In en, this message translates to:
  /// **'Ban Appeals'**
  String get banAppeals;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit Log'**
  String get auditLog;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @totalRecipes.
  ///
  /// In en, this message translates to:
  /// **'Total Recipes'**
  String get totalRecipes;

  /// No description provided for @totalComments.
  ///
  /// In en, this message translates to:
  /// **'Total Comments'**
  String get totalComments;

  /// No description provided for @activeToday.
  ///
  /// In en, this message translates to:
  /// **'Active Today'**
  String get activeToday;

  /// No description provided for @banUser.
  ///
  /// In en, this message translates to:
  /// **'Ban User'**
  String get banUser;

  /// No description provided for @unbanUser.
  ///
  /// In en, this message translates to:
  /// **'Unban User'**
  String get unbanUser;

  /// No description provided for @promoteToAdmin.
  ///
  /// In en, this message translates to:
  /// **'Promote to Admin'**
  String get promoteToAdmin;

  /// No description provided for @demoteToUser.
  ///
  /// In en, this message translates to:
  /// **'Demote to User'**
  String get demoteToUser;

  /// No description provided for @banned.
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get banned;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @banReason.
  ///
  /// In en, this message translates to:
  /// **'Ban Reason'**
  String get banReason;

  /// No description provided for @enterBanReason.
  ///
  /// In en, this message translates to:
  /// **'Enter the reason for banning this user'**
  String get enterBanReason;

  /// No description provided for @confirmBan.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to ban this user?'**
  String get confirmBan;

  /// No description provided for @confirmUnban.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unban this user?'**
  String get confirmUnban;

  /// No description provided for @confirmPromote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to promote this user to admin?'**
  String get confirmPromote;

  /// No description provided for @confirmDemote.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to demote this user?'**
  String get confirmDemote;

  /// No description provided for @recipeCategories.
  ///
  /// In en, this message translates to:
  /// **'Recipe Categories'**
  String get recipeCategories;

  /// No description provided for @foodItemCategories.
  ///
  /// In en, this message translates to:
  /// **'Food Item Categories'**
  String get foodItemCategories;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get editCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @enterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Enter category name'**
  String get enterCategoryName;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this category?'**
  String get confirmDeleteCategory;

  /// No description provided for @createAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Create Announcement'**
  String get createAnnouncement;

  /// No description provided for @announcementTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get announcementTitle;

  /// No description provided for @announcementBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get announcementBody;

  /// No description provided for @confirmDeleteAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this announcement?'**
  String get confirmDeleteAnnouncement;

  /// No description provided for @pendingAppeals.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingAppeals;

  /// No description provided for @allAppeals.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allAppeals;

  /// No description provided for @approveAppeal.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveAppeal;

  /// No description provided for @rejectAppeal.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectAppeal;

  /// No description provided for @reviewNote.
  ///
  /// In en, this message translates to:
  /// **'Review Note'**
  String get reviewNote;

  /// No description provided for @confirmApproveAppeal.
  ///
  /// In en, this message translates to:
  /// **'Approve this appeal and unban the user?'**
  String get confirmApproveAppeal;

  /// No description provided for @confirmRejectAppeal.
  ///
  /// In en, this message translates to:
  /// **'Reject this appeal?'**
  String get confirmRejectAppeal;

  /// No description provided for @appealSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Your appeal has been submitted'**
  String get appealSubmitted;

  /// No description provided for @submitAppeal.
  ///
  /// In en, this message translates to:
  /// **'Submit Appeal'**
  String get submitAppeal;

  /// No description provided for @appealText.
  ///
  /// In en, this message translates to:
  /// **'Explain why your ban should be lifted...'**
  String get appealText;

  /// No description provided for @accountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Account Suspended'**
  String get accountSuspended;

  /// No description provided for @accountSuspendedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended for violating our community guidelines.'**
  String get accountSuspendedMessage;

  /// No description provided for @appealUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Appeal Under Review'**
  String get appealUnderReview;

  /// No description provided for @noUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsers;

  /// No description provided for @noAppeals.
  ///
  /// In en, this message translates to:
  /// **'No appeals'**
  String get noAppeals;

  /// No description provided for @noAuditLogs.
  ///
  /// In en, this message translates to:
  /// **'No audit logs'**
  String get noAuditLogs;

  /// No description provided for @deleteRecipeConfirmAdmin.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recipe? This action cannot be undone.'**
  String get deleteRecipeConfirmAdmin;

  /// No description provided for @viewRecipes.
  ///
  /// In en, this message translates to:
  /// **'View Recipes'**
  String get viewRecipes;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @searchRecipes.
  ///
  /// In en, this message translates to:
  /// **'Search recipes...'**
  String get searchRecipes;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @by.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String by(String name);

  /// No description provided for @activityAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'{title}'**
  String activityAnnouncement(String title);

  /// No description provided for @unitConverter.
  ///
  /// In en, this message translates to:
  /// **'Unit Converter'**
  String get unitConverter;

  /// No description provided for @serves.
  ///
  /// In en, this message translates to:
  /// **'Serves {count}'**
  String serves(int count);

  /// No description provided for @fromUnit.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromUnit;

  /// No description provided for @toUnit.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toUnit;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @tapToConvert.
  ///
  /// In en, this message translates to:
  /// **'Tap to convert'**
  String get tapToConvert;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the email address associated with your account. We\'ll send you a link to reset your password.'**
  String get resetPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// No description provided for @checkYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get checkYourEmail;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a password reset link to\n{email}'**
  String resetLinkSent(String email);

  /// No description provided for @checkInboxDescription.
  ///
  /// In en, this message translates to:
  /// **'Check your inbox and follow the link to reset your password.'**
  String get checkInboxDescription;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @quickLoginTest.
  ///
  /// In en, this message translates to:
  /// **'Quick Login (Test)'**
  String get quickLoginTest;

  /// No description provided for @pleaseSelectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get pleaseSelectDateOfBirth;

  /// No description provided for @pleaseChooseAvailableUsername.
  ///
  /// In en, this message translates to:
  /// **'Please choose an available username'**
  String get pleaseChooseAvailableUsername;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason'**
  String get reasonRequired;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'BASIC INFO'**
  String get basicInfo;

  /// No description provided for @foodItemName.
  ///
  /// In en, this message translates to:
  /// **'Food item name'**
  String get foodItemName;

  /// No description provided for @brandOptional.
  ///
  /// In en, this message translates to:
  /// **'Brand (optional)'**
  String get brandOptional;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @packetSize.
  ///
  /// In en, this message translates to:
  /// **'Packet Size'**
  String get packetSize;

  /// No description provided for @barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get barcode;

  /// No description provided for @invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid'**
  String get invalid;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Fiber'**
  String get fiber;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// No description provided for @sodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodium;

  /// No description provided for @saturatedFat.
  ///
  /// In en, this message translates to:
  /// **'Sat. Fat'**
  String get saturatedFat;

  /// No description provided for @transFat.
  ///
  /// In en, this message translates to:
  /// **'Trans Fat'**
  String get transFat;

  /// No description provided for @cholesterol.
  ///
  /// In en, this message translates to:
  /// **'Cholesterol'**
  String get cholesterol;

  /// No description provided for @salt.
  ///
  /// In en, this message translates to:
  /// **'Salt'**
  String get salt;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'ADDITIONAL INFO'**
  String get additionalInfo;

  /// No description provided for @nutriScore.
  ///
  /// In en, this message translates to:
  /// **'NUTRI-SCORE'**
  String get nutriScore;

  /// No description provided for @novaGroup.
  ///
  /// In en, this message translates to:
  /// **'NOVA GROUP'**
  String get novaGroup;

  /// No description provided for @servingSize.
  ///
  /// In en, this message translates to:
  /// **'SERVING SIZE'**
  String get servingSize;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @ingredientsListOptional.
  ///
  /// In en, this message translates to:
  /// **'List of ingredients (optional)'**
  String get ingredientsListOptional;

  /// No description provided for @allergens.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergens;

  /// No description provided for @addFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Add Food Item'**
  String get addFoodItem;

  /// No description provided for @editFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Food Item'**
  String get editFoodItem;

  /// No description provided for @nutritionAutoConvertInfo.
  ///
  /// In en, this message translates to:
  /// **'Enter nutrition per 1 {unit} — values will be auto-converted to per 100{baseUnit}'**
  String nutritionAutoConvertInfo(String unit, String baseUnit);

  /// No description provided for @allergenPeanuts.
  ///
  /// In en, this message translates to:
  /// **'Peanuts'**
  String get allergenPeanuts;

  /// No description provided for @allergenTreeNuts.
  ///
  /// In en, this message translates to:
  /// **'Tree Nuts'**
  String get allergenTreeNuts;

  /// No description provided for @allergenMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get allergenMilk;

  /// No description provided for @allergenEggs.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get allergenEggs;

  /// No description provided for @allergenFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get allergenFish;

  /// No description provided for @allergenShellfish.
  ///
  /// In en, this message translates to:
  /// **'Shellfish'**
  String get allergenShellfish;

  /// No description provided for @allergenSoy.
  ///
  /// In en, this message translates to:
  /// **'Soy'**
  String get allergenSoy;

  /// No description provided for @allergenSesame.
  ///
  /// In en, this message translates to:
  /// **'Sesame'**
  String get allergenSesame;

  /// No description provided for @allergenGluten.
  ///
  /// In en, this message translates to:
  /// **'Gluten'**
  String get allergenGluten;

  /// No description provided for @nonVegan.
  ///
  /// In en, this message translates to:
  /// **'Non-Vegan'**
  String get nonVegan;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @nutriScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Nutri-Score: {score}'**
  String nutriScoreLabel(String score);

  /// No description provided for @novaGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'NOVA {group}'**
  String novaGroupLabel(String group);

  /// No description provided for @deleteFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Food Item'**
  String get deleteFoodItem;

  /// No description provided for @confirmDeleteFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteFoodItem(String name);

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @nutritionFacts.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts'**
  String get nutritionFacts;

  /// No description provided for @perUnit.
  ///
  /// In en, this message translates to:
  /// **'Per {unit}'**
  String perUnit(String unit);

  /// No description provided for @perPacket.
  ///
  /// In en, this message translates to:
  /// **'Per Packet ({size}{unit})'**
  String perPacket(String size, String unit);

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates;

  /// No description provided for @ratingCommentDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'Your rating and comment will both be deleted.'**
  String get ratingCommentDeleteWarning;

  /// No description provided for @cannotRateOwnRecipe.
  ///
  /// In en, this message translates to:
  /// **'You cannot rate or comment on your own recipe.'**
  String get cannotRateOwnRecipe;

  /// No description provided for @deleteRatingFirst.
  ///
  /// In en, this message translates to:
  /// **'Delete your existing rating first to submit a new one.'**
  String get deleteRatingFirst;

  /// No description provided for @deleteCommentFirst.
  ///
  /// In en, this message translates to:
  /// **'Delete your existing comment first to submit a new one.'**
  String get deleteCommentFirst;

  /// No description provided for @pleaseSelectStarsOrComment.
  ///
  /// In en, this message translates to:
  /// **'Please select stars or write a comment.'**
  String get pleaseSelectStarsOrComment;

  /// No description provided for @deleteCommentToWriteNew.
  ///
  /// In en, this message translates to:
  /// **'Delete your comment to write a new one'**
  String get deleteCommentToWriteNew;

  /// No description provided for @cannotRateOwnRecipeShort.
  ///
  /// In en, this message translates to:
  /// **'You cannot rate your own recipe.'**
  String get cannotRateOwnRecipeShort;

  /// No description provided for @deleteReviewToRerate.
  ///
  /// In en, this message translates to:
  /// **'Delete your review (via the comment card) to re-rate.'**
  String get deleteReviewToRerate;

  /// No description provided for @timerDone.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get timerDone;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @instruction.
  ///
  /// In en, this message translates to:
  /// **'Instruction'**
  String get instruction;

  /// No description provided for @timerSeconds.
  ///
  /// In en, this message translates to:
  /// **'Timer (seconds)'**
  String get timerSeconds;

  /// No description provided for @tapToAddSteps.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add steps'**
  String get tapToAddSteps;

  /// No description provided for @tapToAddIngredients.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add ingredients'**
  String get tapToAddIngredients;

  /// No description provided for @searchMaterials.
  ///
  /// In en, this message translates to:
  /// **'Search materials...'**
  String get searchMaterials;

  /// No description provided for @noMaterialsFound.
  ///
  /// In en, this message translates to:
  /// **'No materials found'**
  String get noMaterialsFound;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @addManually.
  ///
  /// In en, this message translates to:
  /// **'Add manually'**
  String get addManually;

  /// No description provided for @addCustomIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add \"{name}\" manually'**
  String addCustomIngredient(String name);

  /// No description provided for @customIngredient.
  ///
  /// In en, this message translates to:
  /// **'Custom ingredient'**
  String get customIngredient;

  /// No description provided for @ingredientName.
  ///
  /// In en, this message translates to:
  /// **'Ingredient name'**
  String get ingredientName;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @nutritionValues.
  ///
  /// In en, this message translates to:
  /// **'NUTRITION VALUES'**
  String get nutritionValues;

  /// No description provided for @nutritionValuesPer.
  ///
  /// In en, this message translates to:
  /// **'NUTRITION VALUES (per {unit})'**
  String nutritionValuesPer(String unit);

  /// No description provided for @saturatedFatFull.
  ///
  /// In en, this message translates to:
  /// **'Saturated Fat'**
  String get saturatedFatFull;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @foodCategoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get foodCategoryDairy;

  /// No description provided for @foodCategoryGrains.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get foodCategoryGrains;

  /// No description provided for @foodCategoryVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get foodCategoryVegetables;

  /// No description provided for @foodCategoryFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get foodCategoryFruits;

  /// No description provided for @foodCategoryOilsFats.
  ///
  /// In en, this message translates to:
  /// **'Oils & Fats'**
  String get foodCategoryOilsFats;

  /// No description provided for @foodCategoryBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get foodCategoryBeverages;

  /// No description provided for @foodCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get foodCategoryOther;

  /// No description provided for @dietary.
  ///
  /// In en, this message translates to:
  /// **'Dietary'**
  String get dietary;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @physicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Physical Info'**
  String get physicalInfo;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @genderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get genderPreferNotToSay;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activityLightlyActive.
  ///
  /// In en, this message translates to:
  /// **'Lightly Active'**
  String get activityLightlyActive;

  /// No description provided for @activityModeratelyActive.
  ///
  /// In en, this message translates to:
  /// **'Moderately Active'**
  String get activityModeratelyActive;

  /// No description provided for @activityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active'**
  String get activityVeryActive;

  /// No description provided for @activityExtraActive.
  ///
  /// In en, this message translates to:
  /// **'Extra Active'**
  String get activityExtraActive;

  /// No description provided for @cookingSkillLevel.
  ///
  /// In en, this message translates to:
  /// **'Cooking Skill Level'**
  String get cookingSkillLevel;

  /// No description provided for @skillBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get skillBeginner;

  /// No description provided for @skillIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get skillIntermediate;

  /// No description provided for @skillAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get skillAdvanced;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get phoneNumberRequired;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @helpsPersonalizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Optional — helps us personalize your experience'**
  String get helpsPersonalizeExperience;

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editRecipe;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @commentSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Comment submitted'**
  String get commentSubmitted;

  /// No description provided for @ratingSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Rating submitted'**
  String get ratingSubmitted;

  /// No description provided for @welcomeToChefSpecials.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ChefSpecials'**
  String get welcomeToChefSpecials;

  /// No description provided for @discoverCookShare.
  ///
  /// In en, this message translates to:
  /// **'Discover, cook, and share delicious recipes'**
  String get discoverCookShare;

  /// No description provided for @trackYourNutrition.
  ///
  /// In en, this message translates to:
  /// **'Track Your Nutrition'**
  String get trackYourNutrition;

  /// No description provided for @logMealsMonitor.
  ///
  /// In en, this message translates to:
  /// **'Log meals and monitor your daily intake'**
  String get logMealsMonitor;

  /// No description provided for @planYourMeals.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Meals'**
  String get planYourMeals;

  /// No description provided for @organizeWeeklyMealPlan.
  ///
  /// In en, this message translates to:
  /// **'Organize your weekly meal plan'**
  String get organizeWeeklyMealPlan;

  /// No description provided for @shareRecipes.
  ///
  /// In en, this message translates to:
  /// **'Share Recipes'**
  String get shareRecipes;

  /// No description provided for @connectWithFoodLovers.
  ///
  /// In en, this message translates to:
  /// **'Connect with food lovers and share your creations'**
  String get connectWithFoodLovers;

  /// No description provided for @selectDietaryPreferences.
  ///
  /// In en, this message translates to:
  /// **'Select your dietary preferences'**
  String get selectDietaryPreferences;

  /// No description provided for @setDailyGoals.
  ///
  /// In en, this message translates to:
  /// **'Set your daily goals'**
  String get setDailyGoals;

  /// No description provided for @nutFree.
  ///
  /// In en, this message translates to:
  /// **'Nut-Free'**
  String get nutFree;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @addPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// No description provided for @photoGallery.
  ///
  /// In en, this message translates to:
  /// **'Photo Gallery'**
  String get photoGallery;

  /// No description provided for @dragToReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get dragToReorder;

  /// No description provided for @coverPhoto.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get coverPhoto;

  /// No description provided for @morePhotos.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String morePhotos(int count);

  /// No description provided for @photoOf.
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String photoOf(int current, int total);

  /// No description provided for @cookingHistory.
  ///
  /// In en, this message translates to:
  /// **'Cooking History'**
  String get cookingHistory;

  /// No description provided for @iCookedThis.
  ///
  /// In en, this message translates to:
  /// **'I Cooked This'**
  String get iCookedThis;

  /// No description provided for @logCook.
  ///
  /// In en, this message translates to:
  /// **'Log Cook'**
  String get logCook;

  /// No description provided for @cookedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count} serving(s)'**
  String cookedTimes(int count);

  /// No description provided for @cookedCount.
  ///
  /// In en, this message translates to:
  /// **'Cooked {count}×'**
  String cookedCount(int count);

  /// No description provided for @personalNotes.
  ///
  /// In en, this message translates to:
  /// **'Personal notes (optional)'**
  String get personalNotes;

  /// No description provided for @noCookingHistory.
  ///
  /// In en, this message translates to:
  /// **'No cooking history yet'**
  String get noCookingHistory;

  /// No description provided for @noCookingHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap \"I Cooked This\" on any recipe to log your cook'**
  String get noCookingHistorySubtitle;

  /// No description provided for @cookLogged.
  ///
  /// In en, this message translates to:
  /// **'Cook logged!'**
  String get cookLogged;

  /// No description provided for @popularThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Popular This Week'**
  String get popularThisWeek;

  /// No description provided for @trendingRecipes.
  ///
  /// In en, this message translates to:
  /// **'Trending Recipes'**
  String get trendingRecipes;

  /// No description provided for @popularNow.
  ///
  /// In en, this message translates to:
  /// **'Popular Now'**
  String get popularNow;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @spring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get spring;

  /// No description provided for @summer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get summer;

  /// No description provided for @autumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get autumn;

  /// No description provided for @winter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get winter;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @unlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked on {date}'**
  String unlockedOn(String date);

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesome;

  /// No description provided for @viewAllAchievements.
  ///
  /// In en, this message translates to:
  /// **'View all achievements'**
  String get viewAllAchievements;

  /// No description provided for @achievementsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} of {total} unlocked'**
  String achievementsUnlocked(int unlocked, int total);

  /// No description provided for @noAchievementsYet.
  ///
  /// In en, this message translates to:
  /// **'No achievements unlocked yet'**
  String get noAchievementsYet;

  /// No description provided for @categoryCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get categoryCooking;

  /// No description provided for @categorySocial.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get categorySocial;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryExploration.
  ///
  /// In en, this message translates to:
  /// **'Exploration'**
  String get categoryExploration;

  /// No description provided for @achievementFirstRecipe.
  ///
  /// In en, this message translates to:
  /// **'First Recipe'**
  String get achievementFirstRecipe;

  /// No description provided for @achievementFirstRecipeDesc.
  ///
  /// In en, this message translates to:
  /// **'Publish your first recipe'**
  String get achievementFirstRecipeDesc;

  /// No description provided for @achievementRecipeMaster.
  ///
  /// In en, this message translates to:
  /// **'Recipe Master'**
  String get achievementRecipeMaster;

  /// No description provided for @achievementRecipeMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Publish 10 recipes'**
  String get achievementRecipeMasterDesc;

  /// No description provided for @achievementStreak7.
  ///
  /// In en, this message translates to:
  /// **'7-Day Streak'**
  String get achievementStreak7;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In en, this message translates to:
  /// **'Log meals for 7 consecutive days'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementStreak30.
  ///
  /// In en, this message translates to:
  /// **'30-Day Streak'**
  String get achievementStreak30;

  /// No description provided for @achievementStreak30Desc.
  ///
  /// In en, this message translates to:
  /// **'Log meals for 30 consecutive days'**
  String get achievementStreak30Desc;

  /// No description provided for @achievementTopRated.
  ///
  /// In en, this message translates to:
  /// **'Top Rated'**
  String get achievementTopRated;

  /// No description provided for @achievementTopRatedDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach a 5-star average rating'**
  String get achievementTopRatedDesc;

  /// No description provided for @achievementHomeChef.
  ///
  /// In en, this message translates to:
  /// **'Home Chef'**
  String get achievementHomeChef;

  /// No description provided for @achievementHomeChefDesc.
  ///
  /// In en, this message translates to:
  /// **'Cook 10 different recipes'**
  String get achievementHomeChefDesc;

  /// No description provided for @achievementHealthNut.
  ///
  /// In en, this message translates to:
  /// **'Health Nut'**
  String get achievementHealthNut;

  /// No description provided for @achievementHealthNutDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit all macro targets for a week'**
  String get achievementHealthNutDesc;

  /// No description provided for @achievementHydrationHero.
  ///
  /// In en, this message translates to:
  /// **'Hydration Hero'**
  String get achievementHydrationHero;

  /// No description provided for @achievementHydrationHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Hit your water goal 7 days in a row'**
  String get achievementHydrationHeroDesc;

  /// No description provided for @achievementSocialButterfly.
  ///
  /// In en, this message translates to:
  /// **'Social Butterfly'**
  String get achievementSocialButterfly;

  /// No description provided for @achievementSocialButterflyDesc.
  ///
  /// In en, this message translates to:
  /// **'Gain 10 followers'**
  String get achievementSocialButterflyDesc;

  /// No description provided for @achievementSmartShopper.
  ///
  /// In en, this message translates to:
  /// **'Smart Shopper'**
  String get achievementSmartShopper;

  /// No description provided for @achievementSmartShopperDesc.
  ///
  /// In en, this message translates to:
  /// **'Create 5 shopping lists'**
  String get achievementSmartShopperDesc;

  /// No description provided for @achievementCollector.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achievementCollector;

  /// No description provided for @achievementCollectorDesc.
  ///
  /// In en, this message translates to:
  /// **'Create 3 recipe collections'**
  String get achievementCollectorDesc;

  /// No description provided for @achievementExplorer.
  ///
  /// In en, this message translates to:
  /// **'Explorer'**
  String get achievementExplorer;

  /// No description provided for @achievementExplorerDesc.
  ///
  /// In en, this message translates to:
  /// **'Try recipes from 5 categories'**
  String get achievementExplorerDesc;

  /// No description provided for @cookingTime.
  ///
  /// In en, this message translates to:
  /// **'Cooking Time'**
  String get cookingTime;

  /// No description provided for @quickUnder15.
  ///
  /// In en, this message translates to:
  /// **'Quick (< 15 min)'**
  String get quickUnder15;

  /// No description provided for @medium15to30.
  ///
  /// In en, this message translates to:
  /// **'15–30 min'**
  String get medium15to30;

  /// No description provided for @standard30to60.
  ///
  /// In en, this message translates to:
  /// **'30–60 min'**
  String get standard30to60;

  /// No description provided for @longOver60.
  ///
  /// In en, this message translates to:
  /// **'60+ min'**
  String get longOver60;

  /// No description provided for @calorieRange.
  ///
  /// In en, this message translates to:
  /// **'Calorie Range'**
  String get calorieRange;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @maxIngredients.
  ///
  /// In en, this message translates to:
  /// **'Max Ingredients'**
  String get maxIngredients;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent Searches'**
  String get recentSearches;

  /// No description provided for @searchByIngredients.
  ///
  /// In en, this message translates to:
  /// **'Search by Ingredients'**
  String get searchByIngredients;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add an ingredient...'**
  String get addIngredient;

  /// No description provided for @bestMatches.
  ///
  /// In en, this message translates to:
  /// **'Best Matches'**
  String get bestMatches;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @addVideo.
  ///
  /// In en, this message translates to:
  /// **'Add Video'**
  String get addVideo;

  /// No description provided for @recordVideo.
  ///
  /// In en, this message translates to:
  /// **'Record Video'**
  String get recordVideo;

  /// No description provided for @videoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get videoUnavailable;

  /// No description provided for @uploadingVideo.
  ///
  /// In en, this message translates to:
  /// **'Uploading video...'**
  String get uploadingVideo;

  /// No description provided for @compressingVideo.
  ///
  /// In en, this message translates to:
  /// **'Compressing video...'**
  String get compressingVideo;

  /// No description provided for @stepVideo.
  ///
  /// In en, this message translates to:
  /// **'Step Video'**
  String get stepVideo;

  /// No description provided for @recipeVideo.
  ///
  /// In en, this message translates to:
  /// **'Recipe Video'**
  String get recipeVideo;

  /// No description provided for @like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get like;

  /// No description provided for @unlike.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlike;

  /// No description provided for @likes.
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String likes(int count);

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @reportRecipe.
  ///
  /// In en, this message translates to:
  /// **'Report Recipe'**
  String get reportRecipe;

  /// No description provided for @reportComment.
  ///
  /// In en, this message translates to:
  /// **'Report Comment'**
  String get reportComment;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get reportContent;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate Content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonMisinformation.
  ///
  /// In en, this message translates to:
  /// **'Misinformation'**
  String get reportReasonMisinformation;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Thank you.'**
  String get reportSubmitted;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// No description provided for @blockUserConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUserConfirmTitle;

  /// No description provided for @blockUserConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see their content and they won\'t be able to interact with you.'**
  String get blockUserConfirmBody;

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get userBlocked;

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'User unblocked.'**
  String get userUnblocked;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @replies.
  ///
  /// In en, this message translates to:
  /// **'{count} replies'**
  String replies(int count);

  /// No description provided for @viewReplies.
  ///
  /// In en, this message translates to:
  /// **'View {count} replies'**
  String viewReplies(int count);

  /// No description provided for @hideReplies.
  ///
  /// In en, this message translates to:
  /// **'Hide replies'**
  String get hideReplies;

  /// No description provided for @replyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String replyingTo(String name);

  /// No description provided for @cancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get cancelReply;

  /// No description provided for @adminReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminReports;

  /// No description provided for @pendingReports.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingReports;

  /// No description provided for @allReports.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allReports;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reportReviewed.
  ///
  /// In en, this message translates to:
  /// **'Report reviewed.'**
  String get reportReviewed;

  /// No description provided for @reportDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add details (optional)...'**
  String get reportDescriptionHint;

  /// No description provided for @viewProfile.
  ///
  /// In en, this message translates to:
  /// **'View Profile'**
  String get viewProfile;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsers;

  /// No description provided for @noBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get noBlockedUsers;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unitSystem.
  ///
  /// In en, this message translates to:
  /// **'Unit System'**
  String get unitSystem;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

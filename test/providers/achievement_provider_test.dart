import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/providers/achievement_provider.dart';
import 'package:chef_specials/services/achievement_service.dart';

void main() {
  // AchievementProvider.init() defers notifyListeners via
  // WidgetsBinding.instance.addPostFrameCallback, which needs the binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore fakeFirestore;
  late AchievementService service;
  late AchievementProvider provider;

  const userId = 'user1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = AchievementService(firestore: fakeFirestore);
    provider = AchievementProvider(service: service);
  });

  tearDown(() => provider.dispose());

  group('AchievementProvider', () {
    test('initial state is empty', () {
      expect(provider.unlockedAchievements, isEmpty);
      expect(provider.newlyUnlocked, isEmpty);
      expect(provider.unlockedCount, 0);
      expect(provider.totalCount, 12);
    });

    test('init subscribes to stream and loads unlocks', () async {
      await service.unlockAchievement(userId, 'first_recipe');
      provider.init(userId);
      await Future.delayed(Duration.zero);
      expect(provider.unlockedCount, 1);
      expect(provider.isUnlocked('first_recipe'), isTrue);
    });

    test('init is idempotent for same user', () {
      provider.init(userId);
      provider.init(userId);
      // No crash, no duplicate subscription.
    });

    test('checkAchievements unlocks new achievements and adds to newlyUnlocked',
        () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.checkAchievements({'recipesPublished': 1});
      expect(provider.newlyUnlocked.any((a) => a.id == 'first_recipe'),
          isTrue);
    });

    test('checkAchievements does not duplicate', () async {
      await service.unlockAchievement(userId, 'first_recipe');
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.checkAchievements({'recipesPublished': 1});
      expect(provider.newlyUnlocked.any((a) => a.id == 'first_recipe'),
          isFalse);
    });

    test('clearNewlyUnlocked empties the list', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.checkAchievements({'recipesPublished': 1});
      expect(provider.newlyUnlocked.isNotEmpty, isTrue);
      provider.clearNewlyUnlocked();
      expect(provider.newlyUnlocked, isEmpty);
    });

    test('getProgress returns 1.0 for unlocked achievements', () async {
      await service.unlockAchievement(userId, 'first_recipe');
      provider.init(userId);
      await Future.delayed(Duration.zero);

      expect(provider.getProgress('first_recipe'), 1.0);
    });

    test('getProgress reflects context for locked achievements', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.checkAchievements({'recipesPublished': 5});
      expect(provider.getProgress('recipe_master'), closeTo(0.5, 1e-9));
    });

    test('unlockedFor returns the unlock entry', () async {
      await service.unlockAchievement(userId, 'home_chef');
      provider.init(userId);
      await Future.delayed(Duration.zero);

      final entry = provider.unlockedFor('home_chef');
      expect(entry, isNotNull);
      expect(entry!.achievementId, 'home_chef');
    });

    test('unlockedFor returns null when not unlocked', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);
      expect(provider.unlockedFor('home_chef'), isNull);
    });
  });
}

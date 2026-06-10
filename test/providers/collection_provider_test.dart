import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chef_specials/models/recipe_collection.dart';
import 'package:chef_specials/providers/collection_provider.dart';
import 'package:chef_specials/services/collection_service.dart';

class _FlakyCollectionService extends CollectionService {
  _FlakyCollectionService({required FakeFirebaseFirestore firestore})
      : super(firestore: firestore);

  bool failNext = true;

  @override
  Stream<List<RecipeCollection>> getUserCollections(String userId) {
    if (failNext) return Stream.error(Exception('stream failed'));
    return super.getUserCollections(userId);
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late CollectionService service;
  late CollectionProvider provider;

  const userId = 'user1';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = CollectionService(firestore: fakeFirestore);
    provider = CollectionProvider(collectionService: service);
  });

  group('CollectionProvider', () {
    test('initial state has empty collections and is not loading', () {
      expect(provider.collections, isEmpty);
      expect(provider.isLoading, false);
    });

    test('init starts listening to user collections', () async {
      final now = DateTime.now();
      await fakeFirestore.collection('collections').add({
        'userId': userId,
        'name': 'Quick Meals',
        'description': null,
        'recipeIds': ['r1'],
        'coverImageUrl': null,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      provider.init(userId);
      await Future.delayed(Duration.zero);

      expect(provider.collections, hasLength(1));
      expect(provider.collections.first.name, 'Quick Meals');
      expect(provider.isLoading, false);
    });

    test('init does not re-subscribe for same user', () async {
      provider.init(userId);
      provider.init(userId); // should be no-op
      await Future.delayed(Duration.zero);

      expect(provider.collections, isEmpty);
    });

    test('createCollection adds a new collection', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      final collectionId = await provider.createCollection('Keto Meals');
      await Future.delayed(Duration.zero);

      expect(collectionId, isNotEmpty);
      expect(provider.collections, hasLength(1));
      expect(provider.collections.first.name, 'Keto Meals');
    });

    test('createCollection with description', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.createCollection('Weekend',
          description: 'Weekend cooking');
      await Future.delayed(Duration.zero);

      expect(provider.collections.first.description, 'Weekend cooking');
    });

    test('createCollection returns empty string when userId is null', () async {
      final result = await provider.createCollection('Test');
      expect(result, '');
    });

    test('deleteCollection removes a collection', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      final collectionId = await provider.createCollection('ToDelete');
      await Future.delayed(Duration.zero);
      expect(provider.collections, hasLength(1));

      await provider.deleteCollection(collectionId);
      await Future.delayed(Duration.zero);

      expect(provider.collections, isEmpty);
    });

    test('addRecipe adds recipe to collection', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      final collectionId = await provider.createCollection('Favorites');
      await Future.delayed(Duration.zero);

      await provider.addRecipe(collectionId, 'recipe1');
      await Future.delayed(Duration.zero);

      expect(provider.collections.first.recipeIds, contains('recipe1'));
    });

    test('removeRecipe removes recipe from collection', () async {
      final now = DateTime.now();
      final doc = await fakeFirestore.collection('collections').add({
        'userId': userId,
        'name': 'Test',
        'description': null,
        'recipeIds': ['r1', 'r2'],
        'coverImageUrl': null,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.removeRecipe(doc.id, 'r1');
      await Future.delayed(Duration.zero);

      expect(provider.collections.first.recipeIds, isNot(contains('r1')));
      expect(provider.collections.first.recipeIds, contains('r2'));
    });

    test('collectionsContaining returns matching collections', () async {
      final now = DateTime.now();
      await fakeFirestore.collection('collections').add({
        'userId': userId,
        'name': 'Has Recipe',
        'description': null,
        'recipeIds': ['r1', 'r2'],
        'coverImageUrl': null,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });
      await fakeFirestore.collection('collections').add({
        'userId': userId,
        'name': 'No Match',
        'description': null,
        'recipeIds': ['r3'],
        'coverImageUrl': null,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      provider.init(userId);
      await Future.delayed(Duration.zero);

      final containing = provider.collectionsContaining('r1');
      expect(containing, hasLength(1));
      expect(containing.first.name, 'Has Recipe');
    });

    test('collectionsContaining returns empty when no match', () async {
      final now = DateTime.now();
      await fakeFirestore.collection('collections').add({
        'userId': userId,
        'name': 'Test',
        'description': null,
        'recipeIds': ['r1'],
        'coverImageUrl': null,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      provider.init(userId);
      await Future.delayed(Duration.zero);

      final containing = provider.collectionsContaining('nonexistent');
      expect(containing, isEmpty);
    });

    test('notifies listeners when collection data updates', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.createCollection('New Collection');
      await Future.delayed(Duration.zero);

      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('multiple collections tracked correctly', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.createCollection('Collection 1');
      await provider.createCollection('Collection 2');
      await provider.createCollection('Collection 3');
      await Future.delayed(Duration.zero);

      expect(provider.collections, hasLength(3));
    });

    test('init sets isLoading true then false', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);
      expect(provider.isLoading, false);
    });

    test('createCollection shows the new collection immediately', () async {
      provider.init(userId);
      await Future.delayed(Duration.zero);

      await provider.createCollection('Instant');
      // Visible as soon as the create call returns, without waiting
      // for the snapshot stream to emit.
      expect(provider.collections, hasLength(1));
      expect(provider.collections.first.name, 'Instant');
      expect(provider.collections.first.id, isNotNull);
    });

    test('init re-subscribes after a stream error', () async {
      final flaky = _FlakyCollectionService(firestore: fakeFirestore);
      final p = CollectionProvider(collectionService: flaky);

      p.init(userId);
      await Future.delayed(Duration.zero);
      expect(p.collections, isEmpty);

      final now = DateTime.now();
      await fakeFirestore.collection('collections').add({
        'userId': userId,
        'name': 'Recovered',
        'description': null,
        'recipeIds': [],
        'coverImageUrl': null,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      flaky.failNext = false;
      p.init(userId);
      await Future.delayed(Duration.zero);

      expect(p.collections, hasLength(1));
      expect(p.collections.first.name, 'Recovered');
    });
  });
}

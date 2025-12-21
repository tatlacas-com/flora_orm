import 'package:flora_orm/engines/shared_preference_engine.dart';
import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/bloc/test_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferenceEngine<
  TModel extends ModelBase,
  TMeta extends ModelMeta<TModel>
>
    extends SharedPreferenceEngine<TModel, TMeta> {
  MockSharedPreferenceEngine(super.t, {required super.dbContext});

  @override
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  @override
  Future<void> write({
    required String key,
    required Map<String, dynamic> value,
    Map<String, dynamic>? additionalData,
  }) async {
    final items = await getItems() ?? {};
    items[key] = value;
    _mockValues[t.tableName] = jsonEncode(items);
    SharedPreferences.setMockInitialValues(_mockValues);
  }
}

Map<String, Object> _mockValues = {};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(_mockValues);
  group('Test Shared Preferences Storage', () {
    var orm = OrmContext(
      dbVersion: 4,
      engine: DbEngine.sharedPreferences,
      dbName: 'common_storage_db.db',
      tables: const <Model>[TestModel()],
    );
    group('Test engine', () {
      late TestModelStore storage;
      setUpAll(() {
        storage = MockSharedPreferenceEngine(
          const TestModel(),
          dbContext: orm.dbContext,
        );
      });
      test('insert(model) should insert model', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 10,
          testString: 'Testing 123',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
      });

      test(
        'insert(model) should insert model and return expected model',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testDouble: 1,
            testInt: 10,
            testString: 'Testing 1234',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          model = model.copyWith(id: insertedModel!.id);
          expect(insertedModel, model);
        },
      );

      test('insertOrUpdate(model) should insert or update model', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 10,
          testString: 'Testing 12345',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        model = insertedModel!.copyWith(testString: () => 'Updated string');
        final updated = await storage.insertOrUpdate(model);
        expect(updated, isNotNull);
        expect(updated, model);
      });

      test(
        'getModel() with empty columns should throw ArgumentError',
        () async {
          final model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testDouble: 1,
            testInt: 11,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          Future<TestModel?>? fxn() async => storage.firstWhereOrNull(
            select: (t) => [],
            (t) => Filter(t.id, value: insertedModel!.id)
                .and(t.testInt, value: model.testInt)
                .and(t.testBool, value: model.testBool)
                .and(t.testDouble, value: model.testDouble)
                .and(t.testDateTime, value: model.testDateTime),
          );
          await expectLater(fxn(), throwsA(const TypeMatcher<ArgumentError>()));
        },
      );

      test('getModel() should return model with given id', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing xxx',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final json = await storage.firstWhereOrNull(
          (t) => Filter(model.meta.id, value: insertedModel!.id),
        );
        expect(json, isNotNull);
        model = json!;
        expect(insertedModel, model);
      });

      test(
        'getModel() should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testDouble: 1,
            testInt: 11,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            (t) => Filter(model.meta.id, value: insertedModel!.id)
                .and(t.testInt, value: model.testInt)
                .and(t.testBool, value: model.testBool)
                .and(t.testDouble, value: model.testDouble)
                .and(t.testDateTime, value: model.testDateTime),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test(
        'getModel() with columns should return expected model values',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testDouble: 1,
            testInt: 11,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            select: (t) => [t.testInt],
            (t) => Filter(model.meta.id, value: insertedModel!.id)
                .and(t.testInt, value: model.testInt)
                .and(t.testBool, value: model.testBool)
                .and(t.testDouble, value: model.testDouble)
                .and(t.testDateTime, value: model.testDateTime),
          );
          expect(json, isNotNull);
          model = json!;
          expect(model.toString(), const TestModel(testInt: 11).toString());
        },
      );

      test(
        'getModel(NotEqualTo) should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testDouble: 1,
            testInt: 11,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter(
              model.meta.id,
              condition: OrmCondition.isNotEqualTo,
              value: '12',
            ),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test('getModel(Null) should return expected model', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testString: 'Testing 123456',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final json = await storage.firstWhereOrNull(
          orderBy: (t) => [
            OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
          ],
          (t) => Filter(
            t.testInt,
            condition: OrmCondition.isNull,
          ).and(t.testDouble, condition: OrmCondition.isNull),
        );
        expect(json, isNotNull);
        model = json!;
        expect(insertedModel, model);
      });

      test(
        'getModel(NotNull) should return expected model',
        skip: 'Not supported yet',
        () async {
          final model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter(t.testString, condition: OrmCondition.isNotNull),
          );
          expect(json, isNotNull);
          expect(insertedModel, json);
        },
      );

      test('getModel(LessThan) should return expected model', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testInt: -15,
          testString: 'Testing 123456',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final json = await storage.firstWhereOrNull(
          orderBy: (t) => [
            OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
          ],
          (t) =>
              Filter(t.testInt, condition: OrmCondition.isLessThan, value: -14),
        );
        expect(json, isNotNull);
        model = json!;
        expect(insertedModel, model);
      });

      test(
        'getModel(GreaterThan) should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testInt: 20000,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter(
              t.testInt,
              condition: OrmCondition.isGreaterThan,
              value: 19999,
            ),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test(
        'getModel(GreaterThanOrEqual) should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testInt: 100,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter(
              t.testInt,
              condition: OrmCondition.isGreaterThanOrEqual,
              value: 100,
            ),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test(
        'getModel(LessThanOrEqual) should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testInt: -10,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter(
              t.testInt,
              condition: OrmCondition.isGreaterThanOrEqual,
              value: -10,
            ),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test('getModel(Between) should return expected model', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testInt: 1001,
          testString: 'Testing 123456',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final json = await storage.firstWhereOrNull(
          orderBy: (t) => [
            OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
          ],
          (t) => Filter(
            t.testInt,
            condition: OrmCondition.isBetween,
            value: 1000,
            secondaryValue: 1002,
          ),
        );
        expect(json, isNotNull);
        model = json!;
        expect(insertedModel, model);
      });

      test(
        'getModel(NotBetween) should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testInt: 2020,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter(
              t.testInt,
              condition: OrmCondition.isNotBetween,
              value: -500,
              secondaryValue: 2019,
            ),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test('getModel(In) should return expected model', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testInt: 11001,
          testString: 'Testing 123456',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final json = await storage.firstWhereOrNull(
          orderBy: (t) => [
            OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
          ],
          (t) => Filter(
            t.testInt,
            condition: OrmCondition.isIn,
            value: const [11001],
          ),
        );
        expect(json, isNotNull);
        model = json!;
        expect(insertedModel, model);
      });

      test(
        'getModel(NotIn) should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testInt: 11002,
            testString: 'Testing 123456',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter(
              t.testInt,
              condition: OrmCondition.isNotIn,
              value: const [11001, 11005],
            ),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test('getModel(Like) should return expected model', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testInt: 11002,
          testString: 'Likeable',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final json = await storage.firstWhereOrNull(
          orderBy: (t) => [
            OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
          ],
          (t) => Filter(
            t.testString,
            condition: OrmCondition.includes,
            value: '%Like%',
          ),
        );
        expect(json, isNotNull);
        model = json!;
        expect(insertedModel, model);
      });

      test(
        'getModel(NotLike) should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testInt: 11002,
            testString: 'Loveable',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter(
              t.testString,
              condition: OrmCondition.excludes,
              value: '%Dummy%',
            ),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test(
        'getModel() with complex query should return expected model',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testInt: 11002,
            testString: 'Loveable',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final json = await storage.firstWhereOrNull(
            orderBy: (t) => [
              OrmOrder(model.meta.createdAt, direction: OrderDirection.desc),
            ],
            (t) => Filter.startGroup()
                .filter(
                  t.testString,
                  condition: OrmCondition.includes,
                  value: '%Dummy%',
                )
                .and(t.testInt, value: 10)
                .endGroup()
                .or(t.testString, value: 'Loveable', openGroup: true)
                .and(t.testInt, value: 11002, closeGroup: true),
          );
          expect(json, isNotNull);
          model = json!;
          expect(insertedModel, model);
        },
      );

      test('getEntities() should return expected entities', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 12,
          testString: 'Testing b',
        );

        final insertedModel1 = await storage.insert(model1);
        expect(insertedModel1, isNotNull);
        final json = await storage.where(
          (t) => Filter(
            model.meta.id,
            value: insertedModel!.id,
          ).or(model.meta.id, value: insertedModel1!.id),
          orderBy: (t) => [OrmOrder(t.testInt)],
        );
        expect(json, isNotNull);
        final entities = json.map<TestModel>((e) => e).toList();
        expect(entities.length, 2);
        expect(entities, [insertedModel, insertedModel1]);
      });

      test('getEntities() should return empty array', () async {
        const model = TestModel();
        final json = await storage.where(
          (t) => Filter(model.meta.id, value: 'xyzNotFound'),
          orderBy: (t) => [OrmOrder(t.testInt)],
        );
        expect(json, isNotNull);
        expect(json.length, 0);
      });

      test('getEntities() should return items', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );

        final insertedModel = await storage.insert(model);
        final json = await storage.all(
          orderBy: (t) => [OrmOrder(model.meta.createdAt)],
        );
        expect(json, isNotNull);
        expect(json.length, greaterThan(0));
        final entities = json.map<TestModel>((e) => e).toList();
        expect(entities, contains(insertedModel));
      });

      test(
        'getEntities() with orderBy should return '
        'expected entities in expected order',
        skip: 'Not supported yet',
        () async {
          final model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testDouble: 1,
            testInt: 11,
            testString: 'Testing a',
          );

          final insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final model1 = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testDouble: 1,
            testInt: 12,
            testString: 'Testing b',
          );

          final insertedModel1 = await storage.insert(model1);
          expect(insertedModel1, isNotNull);
          final json = await storage.where(
            (t) => Filter(
              model.meta.id,
              value: insertedModel!.id,
            ).or(model.meta.id, value: insertedModel1!.id),
            orderBy: (t) => [
              OrmOrder(t.testInt, direction: OrderDirection.desc),
            ],
          );
          expect(json, isNotNull);
          final entities = json.map<TestModel>((e) => e).toList();
          expect(entities.length, 2);
          expect(entities, [insertedModel1, insertedModel]);
        },
      );

      test('insertList() should insert entities', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );
        final model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 12,
          testString: 'Testing b',
        );
        final insertedModel = await storage.insertList(<TestModel>[
          model,
          model1,
        ]);
        expect(insertedModel, isNotNull);
        expect(insertedModel!.length, 2);
        final a = model.copyWith(id: insertedModel[0].id);
        final b = model1.copyWith(id: insertedModel[1].id);
        expect(insertedModel, [a, b]);
      });

      test('insertList() with duplicate ids should throw', () async {
        final model = TestModel(
          id: 'id1',
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );
        final model1 = TestModel(
          id: 'id1',
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 12,
          testString: 'Testing b',
        );
        expect(
          () async => storage.insertList(<TestModel>[model, model1]),
          throwsA(const TypeMatcher<Exception>()),
        );
      });

      test('update() without columnValues should update model', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        model = (insertedModel!).copyWith(testString: () => 'Updated a');
        final total = await storage.update(
          model: model,
          where: (t) => Filter(model.meta.id, value: model.id),
        );
        expect(total, 1);
      });

      test(
        'update() with columnValues should update',
        skip: 'Not supported yet',
        () async {
          var model = TestModel(
            testBool: true,
            testDateTime: DateTime.now(),
            testDouble: 1,
            testInt: 11,
            testString: 'Testing a',
          );

          var insertedModel = await storage.insert(model);
          expect(insertedModel, isNotNull);
          final total = await storage.update(
            where: (t) => Filter(model.meta.id, value: insertedModel!.id),
            columnValues: (t) => {t.testString: 'Updated ax1'},
          );
          expect(total, 1);
          final json = await storage.firstWhereOrNull(
            (t) => Filter(model.meta.id, value: insertedModel?.id),
          );
          insertedModel = insertedModel?.copyWith(
            testString: () => 'Updated ax1',
          );
          model = json!;
          expect(model, insertedModel);
        },
      );

      test('insertOrUpdateList() should insert entities', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );
        final model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 12,
          testString: 'Testing b',
        );
        final insertedModel = await storage.insertOrUpdateList(<TestModel>[
          model,
          model1,
        ]);
        expect(insertedModel, isNotNull);
        expect(insertedModel!.length, 2);
        final a = model.copyWith(id: insertedModel[0].id);
        final b = model1.copyWith(id: insertedModel[1].id);
        expect(insertedModel, [a, b]);
      });

      test('insertOrUpdateList() should update entities', () async {
        var model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );
        var model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 12,
          testString: 'Testing b',
        );
        var insertedModel = await storage.insertList(<TestModel>[
          model,
          model1,
        ]);
        expect(insertedModel, isNotNull);
        expect(insertedModel!.length, 2);
        model = insertedModel[0].copyWith(testString: () => 'Updated a');
        model1 = insertedModel[1].copyWith(testString: () => 'Updated b');
        insertedModel = await storage.insertOrUpdateList(<TestModel>[
          model,
          model1,
        ]);
        expect(insertedModel, isNotNull);
        expect(insertedModel!.length, 2);
        final a = model.copyWith(id: insertedModel[0].id);
        final b = model1.copyWith(id: insertedModel[1].id);
        expect(insertedModel, [a, b]);
      });

      test('getCount() should throwsUnsupportedError', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );
        final model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 12,
          testString: 'Testing b',
        );
        final insertedModel = await storage.insertList(<TestModel>[
          model,
          model1,
        ]);
        expect(insertedModel, isNotNull);
        expect(insertedModel!.length, 2);

        await expectLater(
          storage.getCount(
            where: (t) => Filter(
              model.meta.id,
              value: insertedModel[0].id,
            ).or(model.meta.id, value: insertedModel[1].id),
          ),
          throwsUnsupportedError,
        );
      });

      test('delete() should delete expected records', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 11,
          testString: 'Testing a',
        );
        final model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 12,
          testString: 'Testing b',
        );
        final insertedModel = await storage.insertList(<TestModel>[
          model,
          model1,
        ]);
        expect(insertedModel, isNotNull);
        expect(insertedModel!.length, 2);
        final total = await storage.delete(
          where: (t) => Filter(
            model.meta.id,
            value: insertedModel[0].id,
          ).or(model.meta.id, value: insertedModel[1].id),
        );
        expect(total, 2);
      });

      test('getSum<int>() should throwsUnsupportedError', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 5,
          testString: 'Testing a',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1,
          testInt: 13,
          testString: 'Testing b',
        );

        final insertedModel1 = await storage.insert(model1);
        expect(insertedModel1, isNotNull);
        await expectLater(
          storage.getSum<int>(column: (t) => t.testInt),
          throwsUnsupportedError,
        );
      });

      test('getSumProduct<double>() should throwsUnsupportedError', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 2,
          testInt: 5,
          testString: 'Testing a',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 3,
          testInt: 20,
          testString: 'Testing b',
        );

        final insertedModel1 = await storage.insert(model1);
        expect(insertedModel1, isNotNull);
        await expectLater(
          storage.getSumProduct<double>(
            select: (t) => [t.testInt, t.testDouble],
            where: (t) => Filter(
              model.meta.id,
              value: insertedModel!.id,
            ).or(model.meta.id, value: insertedModel1!.id),
          ),
          throwsUnsupportedError,
        );
      });

      test('getSum<double>() should throwsUnsupportedError', () async {
        final model = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 1.1,
          testInt: 5,
          testString: 'Testing a',
        );

        final insertedModel = await storage.insert(model);
        expect(insertedModel, isNotNull);
        final model1 = TestModel(
          testBool: true,
          testDateTime: DateTime.now(),
          testDouble: 2.3,
          testInt: 13,
          testString: 'Testing b',
        );

        final insertedModel1 = await storage.insert(model1);
        expect(insertedModel1, isNotNull);
        await expectLater(
          storage.getSum<double>(
            column: (t) => t.testDouble,
            where: (t) => Filter(
              model.meta.id,
              value: insertedModel!.id,
            ).or(model.meta.id, value: insertedModel1!.id),
          ),
          throwsUnsupportedError,
        );
      });

      test('parseInt should return expected int', () {
        expect(storage.parseInt('1'), 1);
      });
    });

    group('Test Db upgrade', () {
      setUp(() async {
        await orm.dbContext.close();
        orm = orm.copyWith(dbVersion: 2);
      });

      test('should upgrade database', () async {
        final dbVersion = await orm.dbContext.getVersion();
        expect(dbVersion, 2);
      });
    });

    group('Test Db upgrade 2', () {
      setUp(() async {
        await orm.dbContext.close();
        orm = orm.copyWith(dbVersion: 3);
      });

      test('should upgrade database', () async {
        final dbVersion = await orm.dbContext.getVersion();
        expect(dbVersion, 3);
      });
    });

    group('Test Unimplemented functions', () {
      test('getDbFullName() should throw UnimplementedError', () {
        expect(
          () async => orm.dbContext.getDbFullName(),
          throwsA(const TypeMatcher<UnimplementedError>()),
        );
      });
      test('getDbPath() should throw UnimplementedError', () {
        expect(
          () async => orm.dbContext.getDbPath(),
          throwsA(const TypeMatcher<UnimplementedError>()),
        );
      });
    });
  });
}

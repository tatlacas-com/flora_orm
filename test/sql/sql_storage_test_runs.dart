import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/bloc/test_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTestGroup
void run(String desc, TestModelStore store) {
  test('insert(model) should insert model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 10,
      testString: 'Testing 123',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
  });

  test('insert(model) should insert model and return expected model', () async {
    var model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 10,
      testString: 'Testing 1234',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    model = model.copyWith(id: insertedModel!.id);
    expect(insertedModel, model);
  });

  test('insertOrUpdate(model) should insert or update model', () async {
    var model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 10,
      testString: 'Testing 12345',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    model = insertedModel!.copyWith(testString: () => 'Updated string');
    final updated = await store.insertOrUpdate(model);
    expect(updated, isNotNull);
    expect(updated, model);
  });

  test(
    'firstWhereOrNull() with empty columns should throw ArgumentError',
    () async {
      final model = TestModel(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1,
        testInt: 11,
        testString: 'Testing 123456',
      );

      final insertedModel = await store.insert(model);
      expect(insertedModel, isNotNull);
      Future<TestModel?>? fxn() async => store.firstWhereOrNull(
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

  test('firstWhereOrNull() should return model with given id', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing xxx',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      (t) => Filter(t.id, value: insertedModel!.id),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull() should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      (t) => Filter(t.id, value: insertedModel!.id)
          .and(t.testInt, value: model.testInt)
          .and(t.testBool, value: model.testBool)
          .and(t.testDouble, value: model.testDouble)
          .and(t.testDateTime, value: model.testDateTime),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test(
    'firstWhereOrNull() with columns should return expected model values',
    () async {
      var model = TestModel(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1,
        testInt: 11,
        testString: 'Testing 123456',
      );

      final insertedModel = await store.insert(model);
      expect(insertedModel, isNotNull);
      final json = await store.firstWhereOrNull(
        select: (t) => [t.testInt],
        (t) => Filter(t.id, value: insertedModel!.id)
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

  test('firstWhereOrNull(isNotEqualTo) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(t.id, condition: OrmCondition.isNotEqualTo, value: '12'),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(isNotEmpty) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      intList: const [1, 2, 3],
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(t.intList, condition: OrmCondition.isNotEmpty),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(isNotEmpty) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(t.intList, condition: OrmCondition.isNotEmpty),
    );
    expect(json, isNull);
  });

  test('firstWhereOrNull(Null) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isNull,
      ).and(t.testDouble, condition: OrmCondition.isNull),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(NotNull) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(t.testString, condition: OrmCondition.isNotNull),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(LessThan) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: -15,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(t.testInt, condition: OrmCondition.isLessThan, value: -14),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(GreaterThan) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 20000,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isGreaterThan,
        value: 19999,
      ),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test(
    'firstWhereOrNull(GreaterThanOrEqual) should return expected model',
    () async {
      final model = TestModel(
        testBool: true,
        testDateTime: DateTime.now(),
        testInt: 100,
        testString: 'Testing 123456',
      );

      final insertedModel = await store.insert(model);
      expect(insertedModel, isNotNull);
      final json = await store.firstWhereOrNull(
        orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
        (t) => Filter(
          t.testInt,
          condition: OrmCondition.isGreaterThanOrEqual,
          value: 100,
        ),
      );
      expect(json, isNotNull);
      expect(insertedModel, json);
    },
  );

  test(
    'firstWhereOrNull(LessThanOrEqual) should return expected model',
    () async {
      final model = TestModel(
        testBool: true,
        testDateTime: DateTime.now(),
        testInt: -10,
        testString: 'Testing 123456',
      );

      final insertedModel = await store.insert(model);
      expect(insertedModel, isNotNull);
      final json = await store.firstWhereOrNull(
        orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
        (t) => Filter(
          t.testInt,
          condition: OrmCondition.isGreaterThanOrEqual,
          value: -10,
        ),
      );
      expect(json, isNotNull);
      expect(insertedModel, json);
    },
  );

  test('firstWhereOrNull(Between) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 1001,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isBetween,
        value: 1000,
        secondaryValue: 1002,
      ),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(NotBetween) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 2020,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isNotBetween,
        value: -500,
        secondaryValue: 2019,
      ),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(isIn) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11001,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) =>
          Filter(t.testInt, condition: OrmCondition.isIn, value: const [11001]),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(isNotIn) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11002,
      testString: 'Testing 123456',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isNotIn,
        value: const [11001, 11005],
      ),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(includes) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11002,
      testString: 'Likeable',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(
        t.testString,
        condition: OrmCondition.includes,
        value: '%Like%',
      ),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('firstWhereOrNull(excludes) should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11002,
      testString: 'Loveable',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
      (t) => Filter(
        t.testString,
        condition: OrmCondition.excludes,
        value: '%Dummy%',
      ),
    );
    expect(json, isNotNull);
    expect(insertedModel, json);
  });

  test('where() with complex query should return expected model', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11002,
      testString: 'Loveable',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final json = await store.firstWhereOrNull(
      orderBy: (t) => [OrmOrder(t.createdAt, direction: OrderDirection.desc)],
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
    expect(insertedModel, json);
  });

  test('where() should return expected entities', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final model1 = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );

    final insertedModel1 = await store.insert(model1);
    expect(insertedModel1, isNotNull);
    final json = await store.where(
      (t) => Filter(
        t.id,
        value: insertedModel!.id,
      ).or(t.id, value: insertedModel1!.id),
      orderBy: (t) => [OrmOrder(t.testInt)],
    );
    expect(json, isNotNull);
    final entities = json.map<TestModel>((e) => e).toList();
    expect(entities.length, 2);
    expect(entities, [insertedModel, insertedModel1]);
  });

  test('where() should return empty array', () async {
    final json = await store.where(
      (t) => Filter(t.id, value: 'xyzNotFound'),
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

    final insertedModel = await store.insert(model);
    final json = await store.all(orderBy: (t) => [OrmOrder(t.createdAt)]);
    expect(json, isNotNull);
    expect(json.length, greaterThan(0));
    final entities = json.map<TestModel>((e) => e).toList();
    expect(entities, contains(insertedModel));
  });

  test('getEntities() with orderBy should return '
      'expected entities in expected order', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final model1 = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );

    final insertedModel1 = await store.insert(model1);
    expect(insertedModel1, isNotNull);
    final json = await store.where(
      (t) => Filter(
        t.id,
        value: insertedModel!.id,
      ).or(t.id, value: insertedModel1!.id),
      orderBy: (t) => [OrmOrder(t.testInt, direction: OrderDirection.desc)],
    );
    expect(json, isNotNull);
    final entities = json.map<TestModel>((e) => e).toList();
    expect(entities.length, 2);
    expect(entities, [insertedModel1, insertedModel]);
  });

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
    final insertedModel = await store.insertList(<TestModel>[model, model1]);
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
      () async => store.insertList(<TestModel>[model, model1]),
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

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    model = (insertedModel!).copyWith(testString: () => 'Updated a');
    final total = await store.update(
      model: model,
      where: (t) => Filter(t.id, value: model.id),
    );
    expect(total, 1);
  });

  test('update() with columnValues should update', () async {
    var model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );

    var insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final total = await store.update(
      where: (t) => Filter(t.id, value: insertedModel!.id),
      columnValues: (t) => {t.testString: 'Updated ax1'},
    );
    expect(total, 1);
    final json = await store.firstWhereOrNull(
      (t) => Filter(t.id, value: insertedModel?.id),
    );
    insertedModel = insertedModel?.copyWith(testString: () => 'Updated ax1');
    model = json!;
    expect(model, insertedModel);
  });

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
    final insertedModel = await store.insertOrUpdateList(<TestModel>[
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
    var insertedModel = await store.insertList(<TestModel>[model, model1]);
    expect(insertedModel, isNotNull);
    expect(insertedModel!.length, 2);
    model = insertedModel[0].copyWith(testString: () => 'Updated a');
    model1 = insertedModel[1].copyWith(testString: () => 'Updated b');
    insertedModel = await store.insertOrUpdateList(<TestModel>[model, model1]);
    expect(insertedModel, isNotNull);
    expect(insertedModel!.length, 2);
    final a = model.copyWith(id: insertedModel[0].id);
    final b = model1.copyWith(id: insertedModel[1].id);
    expect(insertedModel, [a, b]);
  });

  test('getCount() should return correct count', () async {
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
    final insertedModel = await store.insertList(<TestModel>[model, model1]);
    expect(insertedModel, isNotNull);
    expect(insertedModel!.length, 2);
    final total = await store.getCount(
      where: (t) => Filter(
        t.id,
        value: insertedModel[0].id,
      ).or(t.id, value: insertedModel[1].id),
    );
    expect(total, 2);
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
    final insertedModel = await store.insertList(<TestModel>[model, model1]);
    expect(insertedModel, isNotNull);
    expect(insertedModel!.length, 2);
    final total = await store.delete(
      where: (t) => Filter(
        t.id,
        value: insertedModel[0].id,
      ).or(t.id, value: insertedModel[1].id),
    );
    expect(total, 2);
  });

  test('getSum<int>() should return expected sum', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 5,
      testString: 'Testing a',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final model1 = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 13,
      testString: 'Testing b',
    );

    final insertedModel1 = await store.insert(model1);
    expect(insertedModel1, isNotNull);
    var sum = await store.getSum<int>(
      column: (t) => t.testInt,
      where: (t) => Filter(
        t.id,
        value: insertedModel!.id,
      ).or(t.id, value: insertedModel1!.id),
    );
    expect(sum, 18);
    sum = await store.getSum<int>(column: (t) => t.testInt);
    expect(sum, greaterThan(0));
  });

  test('getSumProduct<double>() should return expected sumProduct', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 2,
      testInt: 5,
      testString: 'Testing a',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final model1 = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 3,
      testInt: 20,
      testString: 'Testing b',
    );

    final insertedModel1 = await store.insert(model1);
    expect(insertedModel1, isNotNull);
    final json = await store.getSumProduct<double>(
      select: (t) => [t.testInt, t.testDouble],
      where: (t) => Filter(
        t.id,
        value: insertedModel!.id,
      ).or(t.id, value: insertedModel1!.id),
    );
    expect(json, 70.0);
  });

  test('getSum<double>() should return expected sum', () async {
    final model = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1.1,
      testInt: 5,
      testString: 'Testing a',
    );

    final insertedModel = await store.insert(model);
    expect(insertedModel, isNotNull);
    final model1 = TestModel(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 2.3,
      testInt: 13,
      testString: 'Testing b',
    );

    final insertedModel1 = await store.insert(model1);
    expect(insertedModel1, isNotNull);
    final json = await store.getSum<double>(
      column: (t) => t.testDouble,
      where: (t) => Filter(
        t.id,
        value: insertedModel!.id,
      ).or(t.id, value: insertedModel1!.id),
    );
    expect(json, 3.4);
  });

  test('parseInt should return expected int', () {
    expect(store.parseInt('1'), 1);
  });
}

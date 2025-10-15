import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/bloc/test.entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

@isTestGroup
void run(String desc, TestEntityStore storage) {
  test('insert(entity) should insert entity', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 10,
      testString: 'Testing 123',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
  });

  test('insert(entity) should insert entity and return expected entity',
      () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 10,
      testString: 'Testing 1234',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    entity = entity.copyWith(id: insertedEntity!.id);
    expect(insertedEntity, entity);
  });

  test('insertOrUpdate(entity) should insert or update entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 10,
      testString: 'Testing 12345',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    entity = insertedEntity!.copyWith(testString: () => 'Updated string');
    final updated = await storage.insertOrUpdate(entity);
    expect(updated, isNotNull);
    expect(updated, entity);
  });

  test('getEntity() with empty columns should throw ArgumentError', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    Future<TestEntity?>? fxn() async => storage.firstWhereOrNull(
          select: (t) => [],
          (t) => Filter(
            t.id,
            value: insertedEntity!.id,
          )
              .and(
                t.testInt,
                value: entity.testInt,
              )
              .and(
                t.testBool,
                value: entity.testBool,
              )
              .and(
                t.testDouble,
                value: entity.testDouble,
              )
              .and(
                t.testDateTime,
                value: entity.testDateTime,
              ),
        );
    expect(
      () async => fxn(),
      throwsA(const TypeMatcher<ArgumentError>()),
    );
  });

  test('getEntity() should return entity with given id', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing xxx',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity() should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      )
          .and(
            t.testInt,
            value: entity.testInt,
          )
          .and(
            t.testBool,
            value: entity.testBool,
          )
          .and(
            t.testDouble,
            value: entity.testDouble,
          )
          .and(
            t.testDateTime,
            value: entity.testDateTime,
          ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity() with columns should return expected entity values',
      () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      select: (t) => [t.testInt],
      (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      )
          .and(
            t.testInt,
            value: entity.testInt,
          )
          .and(
            t.testBool,
            value: entity.testBool,
          )
          .and(
            t.testDouble,
            value: entity.testDouble,
          )
          .and(
            t.testDateTime,
            value: entity.testDateTime,
          ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(entity.toString(), const TestEntity(testInt: 11).toString());
  });

  test('getEntity(NotEqualTo) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        entity.meta.id,
        condition: OrmCondition.isNotEqualTo,
        value: '12',
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(Null) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isNull,
      ).and(
        t.testDouble,
        condition: OrmCondition.isNull,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(NotNull) should return expected entity', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testString,
        condition: OrmCondition.isNotNull,
      ),
    );
    expect(json, isNotNull);
    expect(insertedEntity, json);
  });

  test('getEntity(LessThan) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: -15,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isLessThan,
        value: -14,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(GreaterThan) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 20000,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isGreaterThan,
        value: 19999,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(GreaterThanOrEqual) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 100,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isGreaterThanOrEqual,
        value: 100,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(LessThanOrEqual) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: -10,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isGreaterThanOrEqual,
        value: -10,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(Between) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 1001,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isBetween,
        value: 1000,
        secondaryValue: 1002,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(NotBetween) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 2020,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isNotBetween,
        value: -500,
        secondaryValue: 2019,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(In) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11001,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isIn,
        value: const [11001],
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(NotIn) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11002,
      testString: 'Testing 123456',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testInt,
        condition: OrmCondition.isNotIn,
        value: const [11001, 11005],
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(Like) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11002,
      testString: 'Likeable',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testString,
        condition: OrmCondition.includes,
        value: '%Like%',
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(NotLike) should return expected entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11002,
      testString: 'Loveable',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter(
        t.testString,
        condition: OrmCondition.excludes,
        value: '%Dummy%',
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity() with complex query should return expected entity',
      () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testInt: 11002,
      testString: 'Loveable',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final json = await storage.firstWhereOrNull(
      orderBy: (t) => [
        OrmOrder(
          column: entity.meta.createdAt,
          direction: OrderDirection.desc,
        ),
      ],
      (t) => Filter.startGroup()
          .filter(
            t.testString,
            condition: OrmCondition.includes,
            value: '%Dummy%',
          )
          .and(
            t.testInt,
            value: 10,
          )
          .endGroup()
          .or(
            t.testString,
            value: 'Loveable',
            openGroup: true,
          )
          .and(
            t.testInt,
            value: 11002,
            closeGroup: true,
          ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntities() should return expected entities', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );

    final insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    final json = await storage.where(
      (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      ).or(
        entity.meta.id,
        value: insertedEntity1!.id,
      ),
      orderBy: (t) => [OrmOrder(column: t.testInt)],
    );
    expect(json, isNotNull);
    final entities = json.map<TestEntity>((e) => e).toList();
    expect(entities.length, 2);
    expect(entities, [
      insertedEntity,
      insertedEntity1,
    ]);
  });

  test('getEntities() should return empty array', () async {
    const entity = TestEntity();
    final json = await storage.where(
      (t) => Filter(
        entity.meta.id,
        value: 'xyzNotFound',
      ),
      orderBy: (t) => [OrmOrder(column: t.testInt)],
    );
    expect(json, isNotNull);
    expect(json.length, 0);
  });

  test('getEntities() should return items', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );

    final insertedEntity = await storage.insert(entity);
    final json = await storage.all(
      orderBy: (t) => [OrmOrder(column: entity.meta.createdAt)],
    );
    expect(json, isNotNull);
    expect(json.length, greaterThan(0));
    final entities = json.map<TestEntity>((e) => e).toList();
    expect(entities, contains(insertedEntity));
  });

  test(
      'getEntities() with orderBy should return '
      'expected entities in expected order', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );

    final insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    final json = await storage.where(
      (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      ).or(
        entity.meta.id,
        value: insertedEntity1!.id,
      ),
      orderBy: (t) => [
        OrmOrder(
          column: t.testInt,
          direction: OrderDirection.desc,
        ),
      ],
    );
    expect(json, isNotNull);
    final entities = json.map<TestEntity>((e) => e).toList();
    expect(entities.length, 2);
    expect(entities, [
      insertedEntity1,
      insertedEntity,
    ]);
  });

  test('insertList() should insert entities', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );
    final insertedEntity =
        await storage.insertList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    final a = entity.copyWith(id: insertedEntity[0].id);
    final b = entity1.copyWith(id: insertedEntity[1].id);
    expect(insertedEntity, [
      a,
      b,
    ]);
  });

  test('insertList() with duplicate ids should throw', () async {
    final entity = TestEntity(
      id: 'id1',
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );
    final entity1 = TestEntity(
      id: 'id1',
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );
    expect(
      () async => storage.insertList(<TestEntity>[entity, entity1]),
      throwsA(const TypeMatcher<Exception>()),
    );
  });

  test('update() without columnValues should update entity', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    entity = (insertedEntity!).copyWith(testString: () => 'Updated a');
    final total = await storage.update(
      entity: entity,
      where: (t) => Filter(
        entity.meta.id,
        value: entity.id,
      ),
    );
    expect(total, 1);
  });

  test('update() with columnValues should update', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );

    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final total = await storage.update(
      where: (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      ),
      columnValues: (t) => {t.testString: 'Updated ax1'},
    );
    expect(total, 1);
    final json = await storage.firstWhereOrNull(
      (t) => Filter(entity.meta.id, value: insertedEntity?.id),
    );
    insertedEntity = insertedEntity?.copyWith(testString: () => 'Updated ax1');
    entity = json!;
    expect(entity, insertedEntity);
  });

  test('insertOrUpdateList() should insert entities', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );
    final insertedEntity =
        await storage.insertOrUpdateList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    final a = entity.copyWith(id: insertedEntity[0].id);
    final b = entity1.copyWith(id: insertedEntity[1].id);
    expect(insertedEntity, [
      a,
      b,
    ]);
  });

  test('insertOrUpdateList() should update entities', () async {
    var entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );
    var entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );
    var insertedEntity =
        await storage.insertList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    entity = insertedEntity[0].copyWith(testString: () => 'Updated a');
    entity1 = insertedEntity[1].copyWith(testString: () => 'Updated b');
    insertedEntity =
        await storage.insertOrUpdateList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    final a = entity.copyWith(id: insertedEntity[0].id);
    final b = entity1.copyWith(id: insertedEntity[1].id);
    expect(insertedEntity, [
      a,
      b,
    ]);
  });

  test('getCount() should return correct count', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );
    final insertedEntity =
        await storage.insertList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    final total = await storage.getCount(
      where: (t) => Filter(
        entity.meta.id,
        value: insertedEntity[0].id,
      ).or(
        entity.meta.id,
        value: insertedEntity[1].id,
      ),
    );
    expect(total, 2);
  });

  test('delete() should delete expected records', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 11,
      testString: 'Testing a',
    );
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 12,
      testString: 'Testing b',
    );
    final insertedEntity =
        await storage.insertList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    final total = await storage.delete(
      where: (t) => Filter(
        entity.meta.id,
        value: insertedEntity[0].id,
      ).or(
        entity.meta.id,
        value: insertedEntity[1].id,
      ),
    );
    expect(total, 2);
  });

  test('getSum<int>() should return expected sum', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 5,
      testString: 'Testing a',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1,
      testInt: 13,
      testString: 'Testing b',
    );

    final insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    var sum = await storage.getSum<int>(
      column: (t) => t.testInt,
      where: (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      ).or(
        entity.meta.id,
        value: insertedEntity1!.id,
      ),
    );
    expect(sum, 18);
    sum = await storage.getSum<int>(
      column: (t) => t.testInt,
    );
    expect(sum, greaterThan(0));
  });

  test('getSumProduct<double>() should return expected sumProduct', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 2,
      testInt: 5,
      testString: 'Testing a',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 3,
      testInt: 20,
      testString: 'Testing b',
    );

    final insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    final json = await storage.getSumProduct<double>(
      select: (t) => [
        t.testInt,
        t.testDouble,
      ],
      where: (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      ).or(
        entity.meta.id,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, 70.0);
  });

  test('getSum<double>() should return expected sum', () async {
    final entity = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 1.1,
      testInt: 5,
      testString: 'Testing a',
    );

    final insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    final entity1 = TestEntity(
      testBool: true,
      testDateTime: DateTime.now(),
      testDouble: 2.3,
      testInt: 13,
      testString: 'Testing b',
    );

    final insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    final json = await storage.getSum<double>(
      column: (t) => t.testDouble,
      where: (t) => Filter(
        entity.meta.id,
        value: insertedEntity!.id,
      ).or(
        entity.meta.id,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, 3.4);
  });

  test('parseInt should return expected int', () {
    expect(storage.parseInt('1'), 1);
  });
}

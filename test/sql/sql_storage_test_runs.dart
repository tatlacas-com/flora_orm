import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:tatlacas_orm/tatlacas_orm.dart';
import 'package:tatlacas_orm/src/contexts/base_context.dart';
import 'package:tatlacas_orm/src/engines/base_engine.dart';

import '../dummy/test_entity.dart';

@isTest
void run(BaseEngine<TestEntity, BaseContext> storage) {
  test('insert(entity) should insert entity', () async {
    final entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 10,
        testString: 'Testing 123');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
  });

  test('insert(entity) should insert entity and return expected entity',
      () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 10,
        testString: 'Testing 1234');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    entity = entity.copyWith(id: insertedEntity!.id);
    expect(insertedEntity, entity);
  });

  test('insertOrUpdate(entity) should insert or update entity', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 10,
        testString: 'Testing 12345');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    entity = insertedEntity!.copyWith(testString: 'Updated string');
    var updated = await storage.insertOrUpdate(entity);
    expect(updated, isNotNull);
    expect(updated, entity);
  });

  test('getEntity() with empty columns should throw ArgumentError', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    fxn() async => await storage.getEntity(
          columns: (t) => [],
          filter: (t) => Filter.Filter(
            t.columnId,
            value: insertedEntity!.id,
          )
              .and(
                entity.columnTestInt,
                value: entity.testInt,
              )
              .and(
                entity.columnTestBool,
                value: entity.testBool,
              )
              .and(
                entity.columnTestDouble,
                value: entity.testDouble,
              )
              .and(
                entity.columTestDateTime,
                value: entity.testDateTime,
              ),
        );
    expect(
        () async => await fxn(), throwsA(const TypeMatcher<ArgumentError>()));
  });

  test('getEntity() should return expected entity', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity!.id,
      )
          .and(
            entity.columnTestInt,
            value: entity.testInt,
          )
          .and(
            entity.columnTestBool,
            value: entity.testBool,
          )
          .and(
            entity.columnTestDouble,
            value: entity.testDouble,
          )
          .and(
            entity.columTestDateTime,
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
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      columns: (t) => [entity.columnTestInt],
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity!.id,
      )
          .and(
            entity.columnTestInt,
            value: entity.testInt,
          )
          .and(
            entity.columnTestBool,
            value: entity.testBool,
          )
          .and(
            entity.columnTestDouble,
            value: entity.testDouble,
          )
          .and(
            entity.columTestDateTime,
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
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnId,
        condition: SqlCondition.notEqualTo,
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
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.isNull,
      ).and(
        entity.columnTestDouble,
        condition: SqlCondition.isNull,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(NotNull) should return expected entity', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestString,
        condition: SqlCondition.notNull,
      ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntity(LessThan) should return expected entity', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testInt: -15,
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.lessThan,
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
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.greaterThan,
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
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.greaterThanOrEqual,
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
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.greaterThanOrEqual,
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
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.between,
        value: 1000,
        value2: 1002,
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
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.notBetween,
        value: -500,
        value2: 2019,
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
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.isIn,
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
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestInt,
        condition: SqlCondition.notIn,
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
        testString: 'Likeable');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestString,
        condition: SqlCondition.like,
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
        testString: 'Loveable');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnTestString,
        condition: SqlCondition.notLike,
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
        testString: 'Loveable');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnCreatedAt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.lb()
          .filter(
            entity.columnTestString,
            condition: SqlCondition.like,
            value: '%Dummy%',
          )
          .and(
            entity.columnTestInt,
            value: 10,
          )
          .rb()
          .or(
            entity.columnTestString,
            value: 'Loveable',
            lb: true,
          )
          .and(
            entity.columnTestInt,
            value: 11002,
            rb: true,
          ),
    );
    expect(json, isNotNull);
    entity = json!;
    expect(insertedEntity, entity);
  });

  test('getEntities() should return expected entities', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    var json = await storage.getEntities(
      orderBy: (t) => [SqlOrder(column: entity.columnTestInt)],
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, isNotNull);
    var entities = json.map<TestEntity>((e) => e).toList();
    expect(entities.length, 2);
    expect(entities, [
      insertedEntity,
      insertedEntity1,
    ]);
  });

  test('getEntities() should return empty array', () async {
    const entity = TestEntity();
    var json = await storage.getEntities(
      orderBy: (t) => [SqlOrder(column: entity.columnTestInt)],
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: 'xyzNotFound',
      ),
    );
    expect(json, isNotNull);
    expect(json.length, 0);
  });
  test('getEntities() should return items', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity);
    var json = await storage.getEntities(
      orderBy: (t) => [SqlOrder(column: entity.columnCreatedAt)],
    );
    expect(json, isNotNull);
    expect(json.length, greaterThan(0));
    var entities = json.map<TestEntity>((e) => e).toList();
    expect(entities, contains(insertedEntity));
  });

  test(
      'getEntities() with orderBy should return expected entities in expected order',
      () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    var json = await storage.getEntities(
      orderBy: (t) => [
        SqlOrder(
          column: entity.columnTestInt,
          direction: OrderDirection.desc,
        )
      ],
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, isNotNull);
    var entities = json.map<TestEntity>((e) => e).toList();
    expect(entities.length, 2);
    expect(entities, [
      insertedEntity1,
      insertedEntity,
    ]);
  });

  test('insertList() should insert entities', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity =
        await storage.insertList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    var a = entity.copyWith(id: insertedEntity[0].id);
    var b = entity1.copyWith(id: insertedEntity[1].id);
    expect(insertedEntity, [
      a,
      b,
    ]);
  });

  test('update() without columnValues should update entity', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    entity = (insertedEntity as TestEntity).copyWith(testString: 'Updated a');
    var total = await storage.update(
      entity: entity,
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: entity.id,
      ),
    );
    expect(total, 1);
  });

  test('update() with columnValues should update', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var total = await storage.update(
        filter: (t) => Filter.Filter(
              entity.columnId,
              value: insertedEntity!.id,
            ),
        columnValues: (t) => {t.columnTestString: 'Updated ax1'});
    expect(total, 1);
    var json = await storage.getEntity(
        filter: (t) =>
            Filter.Filter(entity.columnId, value: insertedEntity?.id));
    insertedEntity = insertedEntity?.copyWith(testString: 'Updated ax1');
    entity = json!;
    expect(entity, insertedEntity);
  });

  test('insertOrUpdateList() should insert entities', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity =
        await storage.insertOrUpdateList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    var a = entity.copyWith(id: insertedEntity[0].id);
    var b = entity1.copyWith(id: insertedEntity[1].id);
    expect(insertedEntity, [
      a,
      b,
    ]);
  });

  test('insertOrUpdateList() should update entities', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity =
        await storage.insertList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    entity = (insertedEntity[0]).copyWith(testString: 'Updated a');
    entity1 = (insertedEntity[1]).copyWith(testString: 'Updated b');
    insertedEntity =
        await storage.insertOrUpdateList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    var a = entity.copyWith(id: insertedEntity[0].id);
    var b = entity1.copyWith(id: insertedEntity[1].id);
    expect(insertedEntity, [
      a,
      b,
    ]);
  });

  test('getCount() should return correct count', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity =
        await storage.insertList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    var total = await storage.getCount(
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity[0].id,
      ).or(
        entity.columnId,
        value: insertedEntity[1].id,
      ),
    );
    expect(total, 2);
  });

  test('delete() should delete expected records', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity =
        await storage.insertList(<TestEntity>[entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    var total = await storage.delete(
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity[0].id,
      ).or(
        entity.columnId,
        value: insertedEntity[1].id,
      ),
    );
    expect(total, 2);
  });

  test('getSum<int>() should return expected sum', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 5,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 13,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    var sum = await storage.getSum<int>(
      column: (t) => t.columnTestInt,
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(sum, 18);
    sum = await storage.getSum<int>(
      column: (t) => t.columnTestInt,
    );
    expect(sum, greaterThan(0));
  });

  test('getSumProduct<double>() should return expected sumProduct', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 2.0,
        testInt: 5,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 3.0,
        testInt: 20,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    var json = await storage.getSumProduct<double>(
      columns: (t) => [
        entity.columnTestInt,
        entity.columnTestDouble,
      ],
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, 70.0);
  });

  test('getSum<double>() should return expected sum', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.1,
        testInt: 5,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity);
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 2.3,
        testInt: 13,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1);
    expect(insertedEntity1, isNotNull);
    var json = await storage.getSum<double>(
      column: (t) => t.columnTestDouble,
      filter: (t) => Filter.Filter(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, 3.4);
  });

  test('parseInt should return expected int', () {
    expect(storage.parseInt('1'), 1);
  });
}

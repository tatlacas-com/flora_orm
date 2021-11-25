import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';
import 'package:tatlacas_sqflite_storage/sql.dart';
import 'package:tatlacas_sqflite_storage/src/base_storage.dart';
import 'package:tatlacas_sqflite_storage/src/models/sql_order.dart';

import '../dummy/test_entity.dart';

@isTest
void run(BaseStorage storage) {
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
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    expect(insertedEntity, isNotNull);
    entity = insertedEntity!.copyWith(testString: 'Updated string');
    var updated = await storage.insertOrUpdate(entity);
    expect(updated, isNotNull);
    expect(updated, entity);
  });

  test('getEntity() should return expected entity', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing 123456');
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    expect(insertedEntity, isNotNull);
    var json = await storage.getEntity(
      entity,
      where: SqlWhere(
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
    entity = TestEntity().load(json!);
    expect(insertedEntity, entity);
  });

  test('getEntities() should return expected entities', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 11,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1) as TestEntity?;
    expect(insertedEntity1, isNotNull);
    var json = await storage.getEntities(
      entity,
      orderBy: [SqlOrder(column: entity.columnTestInt)],
      where: SqlWhere(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, isNotNull);
    var entities = json.map<TestEntity>((e) => TestEntity().load(e)).toList();
    expect(entities.length, 2);
    expect(entities, [
      insertedEntity,
      insertedEntity1,
    ]);
  });

  test('getEntities() should return empty array', () async {
    final entity = TestEntity();
    var json = await storage.getEntities(
      entity,
      orderBy: [SqlOrder(column: entity.columnTestInt)],
      where: SqlWhere(
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
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    var json = await storage.getEntities(
      entity,
      orderBy: [SqlOrder(column: entity.columnCreatedAt)],
    );
    expect(json, isNotNull);
    expect(json.length, greaterThan(0));
    var entities = json.map<TestEntity>((e) => TestEntity().load(e)).toList();
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
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 12,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1) as TestEntity?;
    expect(insertedEntity1, isNotNull);
    var json = await storage.getEntities(
      entity,
      orderBy: [
        SqlOrder(
          column: entity.columnTestInt,
          direction: OrderDirection.Desc,
        )
      ],
      where: SqlWhere(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, isNotNull);
    var entities = json.map<TestEntity>((e) => TestEntity().load(e)).toList();
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
    var insertedEntity = await storage.insertList([entity, entity1]);
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
      entity,
      where: SqlWhere(
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
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    expect(insertedEntity, isNotNull);
    var total = await storage.update(entity,
        where: SqlWhere(
          entity.columnId,
          value: insertedEntity!.id,
        ),
        columnValues: {entity.columnTestString: 'Updated ax1'});
    expect(total, 1);
    var json = await storage.getEntity(entity,
        where: SqlWhere(entity.columnId, value: insertedEntity.id));
    insertedEntity = insertedEntity.copyWith(testString: 'Updated ax1');
    entity = TestEntity().load(json!);
    expect(entity, insertedEntity);
  });

  test('insertOrUpdateList() should insert or update entities', () async {
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
    var insertedEntity = await storage.insertList([entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    entity =
        (insertedEntity[0] as TestEntity).copyWith(testString: 'Updated a');
    entity1 =
        (insertedEntity[1] as TestEntity).copyWith(testString: 'Updated b');
    insertedEntity = await storage.insertOrUpdateList([entity, entity1]);
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
    var insertedEntity = await storage.insertList([entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    var total = await storage.getCount(
      entity,
      where: SqlWhere(
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
    var insertedEntity = await storage.insertList([entity, entity1]);
    expect(insertedEntity, isNotNull);
    expect(insertedEntity!.length, 2);
    var total = await storage.delete(
      entity,
      where: SqlWhere(
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
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 1.0,
        testInt: 13,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1) as TestEntity?;
    expect(insertedEntity1, isNotNull);
    var json = await storage.getSum<int>(
      entity,
      column: entity.columnTestInt,
      where: SqlWhere(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, 18);
  });
  test('getSumProduct<double>() should return expected sumProduct', () async {
    var entity = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 2.0,
        testInt: 5,
        testString: 'Testing a');
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 3.0,
        testInt: 20,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1) as TestEntity?;
    expect(insertedEntity1, isNotNull);
    var json = await storage.getSumProduct<double>(
      entity,
      columns: [
        entity.columnTestInt,
        entity.columnTestDouble,
      ],
      where: SqlWhere(
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
    var insertedEntity = await storage.insert(entity) as TestEntity?;
    expect(insertedEntity, isNotNull);
    var entity1 = TestEntity(
        testBool: true,
        testDateTime: DateTime.now(),
        testDouble: 2.3,
        testInt: 13,
        testString: 'Testing b');
    var insertedEntity1 = await storage.insert(entity1) as TestEntity?;
    expect(insertedEntity1, isNotNull);
    var json = await storage.getSum<double>(
      entity,
      column: entity.columnTestDouble,
      where: SqlWhere(
        entity.columnId,
        value: insertedEntity!.id,
      ).or(
        entity.columnId,
        value: insertedEntity1!.id,
      ),
    );
    expect(json, 3.4);
  });
}

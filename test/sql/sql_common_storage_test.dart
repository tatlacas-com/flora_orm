import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tatlacas_orm/engines/sqflite_common_engine.dart';
import 'package:tatlacas_orm/src/open_options.dart';

import '../dummy/test_entity.dart';
import 'sql_storage_test_runs.dart';

clearDb(Database database) {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Test Sql Common Storage', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              (MethodCall methodCall) async {
        return '.';
      });
    });
    var dbContext = SqfliteCommonDbContext(
      dbVersion: 1,
      dbName: 'common_storage_db',
      tables: [const TestEntity()],
    );
    var storage = SqfliteCommonEngine<TestEntity, TestEntityMeta>(
        const TestEntity(),
        dbContext: dbContext);
    test('drop database', () async {
      var database = await dbContext.database;
      try {
        await database.rawDelete('drop table if exists ${storage.t.tableName}');
      } catch (e) {
        debugPrint(e.toString());
      }
      await dbContext.close();
      dbContext = dbContext.copyWith(
        dbVersion: 2,
      );
      storage = SqfliteCommonEngine(const TestEntity(), dbContext: dbContext);
      await dbContext.open();
      final dbVersion = await (await dbContext.database).getVersion();
      expect(dbVersion, 2);
    });

    test('SqfliteOpenDatabaseOptions', () async {
      var options = SqfliteOpenDatabaseOptions(version: 1);
      expect(options.toString(),
          '{version: 1, readOnly: false, singleInstance: true}');
    });

    run(storage);

    group('Test Db upgrade', () {
      test('should upgrade database', () async {
        await dbContext.close();
        dbContext = dbContext.copyWith(
          dbVersion: 4,
        );
        storage = SqfliteCommonEngine(const TestEntity(), dbContext: dbContext);
        await dbContext.open();
        storage.insert(const TestEntity(testString: 'Okay'));
        final dbVersion = await (await dbContext.database).getVersion();
        expect(dbVersion, 4);
      });
    });

    group('Test Db downgrade', () {
      test('should upgrade database', () async {
        await dbContext.close();
        dbContext = dbContext.copyWith(
          dbVersion: 3,
        );
        storage = SqfliteCommonEngine(const TestEntity(), dbContext: dbContext);
        await dbContext.open();
        storage.insert(const TestEntity(testString: 'Okay'));
        final dbVersion = await (await dbContext.database).getVersion();
        expect(dbVersion, 3);
      });
    });
  });
}

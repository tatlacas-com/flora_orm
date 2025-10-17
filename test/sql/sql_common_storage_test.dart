import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/bloc/test.entity.dart';
import 'package:flora_orm/src/open_options.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'sql_storage_test_runs.dart';

void clearDb(Database database) {}

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
    var orm = OrmContext(
      dbVersion: 4,
      engine: DbEngine.sqfliteCommon,
      dbName: 'common_storage_db.db',
      tables: const <Entity>[
        TestEntity(),
      ],
    );

    final TestEntityStore store = orm.getStore(const TestEntity());

    /* test('drop database', () async {
      var database = await orm.dbContext.database;
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
    }); */

    test('SqfliteOpenDatabaseOptions', () async {
      final options = SqfliteOpenDatabaseOptions(version: 1);
      expect(
        options.toString(),
        '{version: 1, readOnly: false, singleInstance: true}',
      );
    });

    run('Test engine', store);

    group('Test Db upgrade', () {
      setUp(() async {
        await orm.dbContext.close();
        orm = orm.copyWith(dbVersion: 3);
      });

      test('should upgrade database', () async {
        final dbVersion = await orm.dbContext.getVersion();
        expect(dbVersion, 3);
      });
    });
  });
}

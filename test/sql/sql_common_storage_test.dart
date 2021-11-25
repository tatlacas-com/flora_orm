import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:tatlacas_sqflite_storage/sqflite_common_storage.dart';

import '../dummy/test_entity.dart';
import 'sql_storage_test_runs.dart';

clearDb(Database database) {}

void main() {
  group('Test Sql Common Storage', () {
    var dbContext = SqfliteCommonDbContext(
      dbVersion: 1,
      dbName: 'common_storage_db',
      tables: [TestEntity()],
    );
    var storage = SqfliteCommonStorage(dbContext: dbContext);
    test('drop database', () async {
      var database = await dbContext.database;
      try{
        await database.delete(TestEntity().tableName);
      }catch(e){}
      await dbContext.close();
      dbContext = dbContext.copyWith(
        dbVersion: 2,
      );
      storage = SqfliteCommonStorage(dbContext: dbContext);
      await dbContext.open();
    });

    run(storage);

    group('Test Db upgrade', () {
      late Database database;
      setUp(() async {
        await dbContext.close();
        dbContext = dbContext.copyWith(
          dbVersion: 2,
        );
        storage = SqfliteCommonStorage(dbContext: dbContext);
        database = await dbContext.database;
      });

      test('should upgrade database', () async {
        final dbVersion = await database.getVersion();
        expect(dbVersion, 2);
      });
    });
  });
}

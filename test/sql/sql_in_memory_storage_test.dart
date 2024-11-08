import 'package:flora_orm/src/bloc/test.entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flora_orm/engines/sqflite_in_memory_engine.dart';
import 'package:flora_orm/flora_orm.dart';

import 'sql_storage_test_runs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Test Sql In Memory Storage', () {
    var dbContext = SqfliteInMemoryDbContext<TestEntity>(
      dbVersion: 1,
      dbName: 'common_storage_db',
      tables: <IEntity>[const TestEntity()],
    );
    var storage = SqfliteInMemoryEngine<TestEntity, TestEntityMeta>(
      const TestEntity(),
      dbContext: dbContext,
    );

    group('Test Db upgrade', () {
      late Database database;
      setUp(() async {
        await dbContext.close();
        dbContext = dbContext.copyWith(
          dbVersion: 2,
        );
        storage =
            SqfliteInMemoryEngine(const TestEntity(), dbContext: dbContext);
        database = await dbContext.database;
      });

      test('should upgrade database', () async {
        final dbVersion = await database.getVersion();
        expect(dbVersion, 2);
      });
    });
    run(storage);

    group('Test Db upgrade', () {
      late Database database;
      setUp(() async {
        await dbContext.close();
        dbContext = dbContext.copyWith(
          dbVersion: 3,
        );
        storage =
            SqfliteInMemoryEngine(const TestEntity(), dbContext: dbContext);
        database = await dbContext.database;
      });

      test('should upgrade database', () async {
        final dbVersion = await database.getVersion();
        expect(dbVersion, 3);
      });
    });

    test('getDbFullName() should throw UnimplementedError', () {
      expect(() async => await dbContext.getDbFullName(),
          throwsA(const TypeMatcher<UnimplementedError>()));
    });
    test('getDbPath() should throw UnimplementedError', () {
      expect(() async => await dbContext.getDbPath(),
          throwsA(const TypeMatcher<UnimplementedError>()));
    });
  });
}

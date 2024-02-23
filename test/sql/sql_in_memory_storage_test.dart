import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tatlacas_sqflite_storage/sqflite_in_memory_storage.dart';
import 'package:tatlacas_sqflite_storage/sql.dart';

import '../dummy/test_entity.dart';
import 'sql_storage_test_runs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Test Sql In Memory Storage', () {
    var dbContext = SqfliteInMemoryDbContext(
      dbVersion: 1,
      dbName: 'common_storage_db',
      tables: <IEntity>[const TestEntity()],
    );
    var storage = SqfliteInMemoryStorage(const TestEntity(), dbContext: dbContext);

    group('Test Db upgrade', () {
      late Database database;
      setUp(() async {
        await dbContext.close();
        dbContext = dbContext.copyWith(
          dbVersion: 2,
        );
        storage = SqfliteInMemoryStorage(const TestEntity(), dbContext: dbContext);
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
        storage = SqfliteInMemoryStorage(const TestEntity(), dbContext: dbContext);
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

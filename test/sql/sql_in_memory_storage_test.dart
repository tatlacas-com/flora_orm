import 'package:flora_orm/src/bloc/test.entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flora_orm/flora_orm.dart';

import 'sql_storage_test_runs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Test Sql In Memory Storage', () {
    var orm = OrmManager(
      dbVersion: 1,
      engine: DbEngine.inMemory,
      dbName: 'common_storage_db.db',
      tables: <Entity>[
        const TestEntity(),
      ],
    );

    TestEntityOrm storage = orm.getStorage(const TestEntity());

    group('Test Db upgrade', () {
      setUp(() async {
        await orm.dbContext.close();
        orm = orm.copyWith(dbVersion: 2);
        storage = orm.getStorage(const TestEntity());
      });

      test('should upgrade database', () async {
        final dbVersion = await orm.dbContext.getVersion();
        expect(dbVersion, 2);
      });
    });
    run(storage);

    group('Test Db upgrade', () {
      setUp(() async {
        await orm.dbContext.close();
        orm = orm.copyWith(dbVersion: 3);
        storage = orm.getStorage(const TestEntity());
      });

      test('should upgrade database', () async {
        final dbVersion = await orm.dbContext.getVersion();
        expect(dbVersion, 3);
      });
    });

    test('getDbFullName() should throw UnimplementedError', () {
      expect(() async => await orm.dbContext.getDbFullName(),
          throwsA(const TypeMatcher<UnimplementedError>()));
    });
    test('getDbPath() should throw UnimplementedError', () {
      expect(() async => await orm.dbContext.getDbPath(),
          throwsA(const TypeMatcher<UnimplementedError>()));
    });
  });
}

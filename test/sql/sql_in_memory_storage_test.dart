import 'package:flora_orm/src/bloc/test.entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flora_orm/flora_orm.dart';

import 'sql_storage_test_runs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Test Sql In Memory Storage', () {
    var orm = OrmManager(
      dbVersion: 4,
      engine: DbEngine.inMemory,
      dbName: 'common_storage_db.db',
      tables: <Entity>[
        const TestEntity(),
      ],
    );

    group('Test Engine', () {
      TestEntityOrm storage = orm.getStorage(const TestEntity());
      run('Test engine', storage);
    });
    group('Test Db upgrade', () {
      setUp(() async {
        await orm.dbContext.close();
        orm = orm.copyWith(dbVersion: 2);
      });

      test('should upgrade database', () async {
        final dbVersion = await orm.dbContext.getVersion();
        expect(dbVersion, 2);
      });
    });

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

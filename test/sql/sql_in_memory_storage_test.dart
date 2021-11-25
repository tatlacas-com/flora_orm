import 'package:flutter_test/flutter_test.dart';
import 'package:tatlacas_sqflite_storage/sqflite_in_memory_storage.dart';

import '../dummy/test_entity.dart';
import 'sql_storage_test_runs.dart';

void main() {
  group('Test Sql In Memory Storage', () {
    final dbContext = SqfliteInMemoryDbContext(
      dbVersion: 1,
      dbName: 'common_storage_db',
      tables: [TestEntity()],
    );
    final SqfliteInMemoryStorage storage =
        SqfliteInMemoryStorage(dbContext: dbContext);
    run(storage);

    test('getDbFullName() should throw UnimplementedError', () {
      expect(() async => await dbContext.getDbFullName(),
          throwsA(const TypeMatcher<UnimplementedError>()));
    });
    test('getDbPath() should throw UnimplementedError', () {
      expect(() async => await dbContext.getDbPath(), throwsA(const TypeMatcher<UnimplementedError>()));
    });
  });
}

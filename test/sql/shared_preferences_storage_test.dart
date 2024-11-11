import 'package:flora_orm/engines/shared_preference_engine.dart';
import 'package:flora_orm/src/bloc/test.entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flora_orm/flora_orm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sql_storage_test_runs.dart';

class MockSharedPreferenceEngine<TEntity extends IEntity,
        TMeta extends EntityMeta<TEntity>>
    extends SharedPreferenceEngine<TEntity, TMeta> {
  MockSharedPreferenceEngine(super.t, {required super.dbContext});

  @override
  Future<void> write(
      {required String key,
      required String? value,
      Map<String, dynamic>? additionalData}) async {
    _mockValues[key] = value ?? '';
    SharedPreferences.setMockInitialValues(_mockValues);
  }
}

Map<String, Object> _mockValues = {};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(_mockValues);
  group('Test Shared Preferences Storage', () {
    var orm = OrmManager(
      dbVersion: 1,
      engine: DbEngine.sharedPreferences,
      dbName: 'common_storage_db.db',
      tables: <Entity>[
        const TestEntity(),
      ],
    );
    group('Test engine', () {
      TestEntityOrm storage = MockSharedPreferenceEngine(
        const TestEntity(),
        dbContext: orm.dbContext,
      );

      run(storage);
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

    group('Test Db upgrade 2', () {
      setUp(() async {
        await orm.dbContext.close();
        orm = orm.copyWith(dbVersion: 3);
      });

      test('should upgrade database', () async {
        final dbVersion = await orm.dbContext.getVersion();
        expect(dbVersion, 3);
      });
    });

    group('Test Unimplemented functions', () {
      test('getDbFullName() should throw UnimplementedError', () {
        expect(() async => await orm.dbContext.getDbFullName(),
            throwsA(const TypeMatcher<UnimplementedError>()));
      });
      test('getDbPath() should throw UnimplementedError', () {
        expect(() async => await orm.dbContext.getDbPath(),
            throwsA(const TypeMatcher<UnimplementedError>()));
      });
    });
  });
}

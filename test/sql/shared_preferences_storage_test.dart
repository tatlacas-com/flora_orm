import 'package:flora_orm/engines/shared_preference_engine.dart';
import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/bloc/test.entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'sql_storage_test_runs.dart';

class MockSharedPreferenceEngine<TEntity extends IEntity,
        TMeta extends EntityMeta<TEntity>>
    extends SharedPreferenceEngine<TEntity, TMeta> {
  MockSharedPreferenceEngine(super.t, {required super.dbContext});

  @override
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  @override
  Future<void> write(
      {required String key,
      required Map<String, dynamic> value,
      Map<String, dynamic>? additionalData,}) async {
    final items = await getItems() ?? {};
    items[key] = value;
    _mockValues[t.tableName] = jsonEncode(items);
    SharedPreferences.setMockInitialValues(_mockValues);
  }
}

Map<String, Object> _mockValues = {};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(_mockValues);
  group('Test Shared Preferences Storage', () {
    var orm = OrmContext(
      dbVersion: 4,
      engine: DbEngine.sharedPreferences,
      dbName: 'common_storage_db.db',
      tables: const <Entity>[
        TestEntity(),
      ],
    );
    run(
      'Test engine',
      MockSharedPreferenceEngine(
        const TestEntity(),
        dbContext: orm.dbContext,
      ),
    );

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
        expect(() async => orm.dbContext.getDbFullName(),
            throwsA(const TypeMatcher<UnimplementedError>()),);
      });
      test('getDbPath() should throw UnimplementedError', () {
        expect(() async => orm.dbContext.getDbPath(),
            throwsA(const TypeMatcher<UnimplementedError>()),);
      });
    });
  });
}

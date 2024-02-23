import 'package:tatlacas_sqflite_storage/sql.dart';

class TestEntity extends Entity<TestEntity> {

  const TestEntity({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.testString,
    this.testUpgrade,
    this.testDateTime,
    this.testInt,
    this.testIntWithDefault,
    this.testBool,
    this.testDouble,
  });
  final String? testString;
  final String? testUpgrade;
  final DateTime? testDateTime;
  final int? testInt;
  final int? testIntWithDefault;
  final bool? testBool;
  final double? testDouble;

  get columnTestString => SqlColumn<TestEntity, String>(
        'testString',
        write: (entity) => entity.testString,
        read: (json, entity, value) => entity.copyWith(testString: value),
      );

  get columnTestUpgrade => SqlColumn<TestEntity, String>(
        'testUpgrade',
        write: (entity) => entity.testUpgrade,
        read: (json, entity, value) => entity.copyWith(testUpgrade: value),
      );

  get columTestDateTime => SqlColumn<TestEntity, DateTime>(
        'testDateTime',
        write: (entity) => entity.testDateTime,
        read: (json, entity, value) => entity.copyWith(testDateTime: value),
      );

  get columnTestInt => SqlColumn<TestEntity, int>(
        'testInt',
        write: (entity) => entity.testInt,
        read: (json, entity, value) => entity.copyWith(testInt: value),
      );

  get columnTestIntWithDefault => SqlColumn<TestEntity, int>(
        'testIntWithDefault',
        write: (entity) => entity.testIntWithDefault,
        defaultValue: 100,
        read: (json, entity, value) =>
            entity.copyWith(testIntWithDefault: value),
      );

  get columnTestBool => SqlColumn<TestEntity, bool>(
        'testBool',
        write: (entity) => entity.testBool,
        read: (json, entity, value) => entity.copyWith(testBool: value),
      );

  get columnTestDouble => SqlColumn<TestEntity, double>(
        'testDouble',
        write: (entity) => entity.testDouble,
        read: (json, entity, value) => entity.copyWith(testDouble: value),
      );

  @override
  TestEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? testString,
    String? testUpgrade,
    DateTime? testDateTime,
    int? testInt,
    int? testIntWithDefault,
    bool? testBool,
    double? testDouble,
    Map<String, dynamic>? json,
  }) {
    return TestEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      testString: testString ?? this.testString,
      testUpgrade: testUpgrade ?? this.testUpgrade,
      testDateTime: testDateTime ?? this.testDateTime,
      testInt: testInt ?? this.testInt,
      testIntWithDefault: testIntWithDefault ?? this.testIntWithDefault,
      testBool: testBool ?? this.testBool,
      testDouble: testDouble ?? this.testDouble,
    );
  }

  @override
  Iterable<SqlColumn<TestEntity, dynamic>> get columns => [
        columnTestString,
        columnTestDouble,
        columTestDateTime,
        columnTestBool,
        columnTestIntWithDefault,
        columnTestInt,
      ];

  @override
  String get tableName => 'test_entity';

  @override
  List<String> upgradeTable(int oldVersion, int newVersion) {
    if (newVersion == 2) {
      return [
        dropTable(tableName),
        createTable(newVersion),
      ];
    }
    if (newVersion == 4) {
      return [addColumn(columnTestUpgrade)];
    }
    return [];
  }

  @override
  List<Object?> get props => super.props.followedBy([
        testString,
        testDateTime,
        testInt,
        testBool,
        testUpgrade,
        testIntWithDefault,
        testDouble,
      ]).toList();
}

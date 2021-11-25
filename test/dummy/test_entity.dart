import 'package:tatlacas_sqflite_storage/sql.dart';

class TestEntity extends Entity<TestEntity> {
  final String? testString;
  final String? testUpgrade;
  final DateTime? testDateTime;
  final int? testInt;
  final bool? testBool;
  final double? testDouble;

  get columnTestString => SqlColumn<TestEntity, String>(
        'testString',
        read: (entity) => entity.testString,
        write: (entity, value) => entity.copyWith(testString: value),
      );

  get columnTestUpgrade => SqlColumn<TestEntity, String>(
        'testUpgrade',
        read: (entity) => entity.testUpgrade,
        write: (entity, value) => entity.copyWith(testUpgrade: value),
      );

  get columTestDateTime => SqlColumn<TestEntity, DateTime>(
        'testDateTime',
        read: (entity) => entity.testDateTime,
        write: (entity, value) => entity.copyWith(testDateTime: value),
      );

  get columnTestInt => SqlColumn<TestEntity, int>(
        'testInt',
        read: (entity) => entity.testInt,
        write: (entity, value) => entity.copyWith(testInt: value),
      );

  get columnTestBool => SqlColumn<TestEntity, bool>(
        'testBool',
        read: (entity) => entity.testBool,
        write: (entity, value) => entity.copyWith(testBool: value),
      );

  get columnTestDouble => SqlColumn<TestEntity, double>(
        'testDouble',
        read: (entity) => entity.testDouble,
        write: (entity, value) => entity.copyWith(testDouble: value),
      );

  const TestEntity({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.testString,
    this.testUpgrade,
    this.testDateTime,
    this.testInt,
    this.testBool,
    this.testDouble,
  }) : super(id: id, createdAt: createdAt, updatedAt: updatedAt);

  TestEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? testString,
    String? testUpgrade,
    DateTime? testDateTime,
    int? testInt,
    bool? testBool,
    double? testDouble,
  }) {
    return TestEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      testString: testString ?? this.testString,
      testUpgrade: testUpgrade ?? this.testUpgrade,
      testDateTime: testDateTime ?? this.testDateTime,
      testInt: testInt ?? this.testInt,
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
        columnTestInt,
      ];

  @override
  TestEntity setBaseParams(
      {String? id, DateTime? createdAt, DateTime? updatedAt}) {
    return this.copyWith(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String get tableName => 'test_entity';

  @override
  List<String> upgradeTable(int oldVersion, int newVersion) {
    if (newVersion == 2) {
      return [createTable(newVersion)];
    }
    if (newVersion == 3) {
      return [alterTableAddColumn(columnTestUpgrade)];
    }
    return [];
  }

  @override
  List<Object?> get props => super.props.followedBy([
        testString,
        testDateTime,
        testInt,
        testBool,
        testDouble,
      ]).toList();
}

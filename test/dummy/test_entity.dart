import 'package:tatlacas_orm/tatlacas_orm.dart';

class TestEntityMeta extends EntityMeta<TestEntity> {
  const TestEntityMeta();

  @override
  String get tableName => 'test_entity';
  @override
  Iterable<OrmColumn<TestEntity, dynamic>> get columns =>
      throw UnimplementedError();

  @override
  OrmColumn<IEntity, DateTime> get createdAt => throw UnimplementedError();

  @override
  OrmColumn<IEntity, String> get id => throw UnimplementedError();

  @override
  OrmColumn<IEntity, DateTime> get updatedAt => throw UnimplementedError();

  get testString => OrmColumn<TestEntity, String>(
        'testString',
        write: (entity) => entity.testString,
        read: (json, entity, value) => entity.copyWith(testString: value),
      );

  get testUpgrade => OrmColumn<TestEntity, String>(
        'testUpgrade',
        write: (entity) => entity.testUpgrade,
        read: (json, entity, value) => entity.copyWith(testUpgrade: value),
      );

  get testDateTime => OrmColumn<TestEntity, DateTime>(
        'testDateTime',
        write: (entity) => entity.testDateTime,
        read: (json, entity, value) => entity.copyWith(testDateTime: value),
      );

  get testInt => OrmColumn<TestEntity, int>(
        'testInt',
        write: (entity) => entity.testInt,
        read: (json, entity, value) => entity.copyWith(testInt: value),
      );

  get testIntWithDefault => OrmColumn<TestEntity, int>(
        'testIntWithDefault',
        write: (entity) => entity.testIntWithDefault,
        defaultValue: 100,
        read: (json, entity, value) =>
            entity.copyWith(testIntWithDefault: value),
      );

  get testBool => OrmColumn<TestEntity, bool>(
        'testBool',
        write: (entity) => entity.testBool,
        read: (json, entity, value) => entity.copyWith(testBool: value),
      );

  get testDouble => OrmColumn<TestEntity, double>(
        'testDouble',
        write: (entity) => entity.testDouble,
        read: (json, entity, value) => entity.copyWith(testDouble: value),
      );
}

class TestEntity extends Entity<TestEntity, TestEntityMeta> {
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
  List<String> upgradeTable(int oldVersion, int newVersion) {
    if (newVersion == 2) {
      return [
        dropTable(meta.tableName),
        createTable(newVersion),
      ];
    }
    if (newVersion == 4) {
      return [addColumn(meta.testUpgrade)];
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

  @override
  final TestEntityMeta meta = const TestEntityMeta();
}

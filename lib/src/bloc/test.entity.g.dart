// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.entity.dart';

// **************************************************************************
// EntityPropsGenerator
// **************************************************************************

mixin _TestEntityMixin on Entity<TestEntity, TestEntityMeta> {
  static const TestEntityMeta _meta = TestEntityMeta();

  @override
  TestEntityMeta get meta => _meta;

  String? get testString;
  String? get testUpgrade;
  DateTime? get testDateTime;
  int? get testInt;
  int? get testIntWithDefault;
  bool? get testBool;
  double? get testDouble;

  @override
  List<Object?> get props => [
        ...super.props,
        testString,
        testUpgrade,
        testDateTime,
        testInt,
        testIntWithDefault,
        testBool,
        testDouble,
      ];
  @override
  TestEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    CopyWith<String?>? testString,
    CopyWith<String?>? testUpgrade,
    CopyWith<DateTime?>? testDateTime,
    CopyWith<int?>? testInt,
    CopyWith<int?>? testIntWithDefault,
    CopyWith<bool?>? testBool,
    CopyWith<double?>? testDouble,
    Map<String, dynamic>? json,
  }) {
    return TestEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      testString: testString != null ? testString.value : this.testString,
      testUpgrade: testUpgrade != null ? testUpgrade.value : this.testUpgrade,
      testDateTime:
          testDateTime != null ? testDateTime.value : this.testDateTime,
      testInt: testInt != null ? testInt.value : this.testInt,
      testIntWithDefault: testIntWithDefault != null
          ? testIntWithDefault.value
          : this.testIntWithDefault,
      testBool: testBool != null ? testBool.value : this.testBool,
      testDouble: testDouble != null ? testDouble.value : this.testDouble,
    );
  }
}
typedef TestEntityOrm
    = OrmEngine<TestEntity, TestEntityMeta, DbContext<TestEntity>>;

class TestEntityMeta extends EntityMeta<TestEntity> {
  const TestEntityMeta();

  @override
  String get tableName => 'test';

  @override
  ColumnDefinition<TestEntity, String> get id =>
      ColumnDefinition<TestEntity, String>(
        'id',
        primaryKey: true,
        write: (entity) => entity.id,
        read: (json, entity, value) => entity.copyWith(id: value, json: json),
      );

  @override
  ColumnDefinition<TestEntity, DateTime> get createdAt =>
      ColumnDefinition<TestEntity, DateTime>(
        'createdAt',
        write: (entity) => entity.createdAt,
        read: (json, entity, value) =>
            entity.copyWith(createdAt: value, json: json),
      );

  @override
  ColumnDefinition<TestEntity, DateTime> get updatedAt =>
      ColumnDefinition<TestEntity, DateTime>(
        'updatedAt',
        write: (entity) => entity.updatedAt,
        read: (json, entity, value) =>
            entity.copyWith(updatedAt: value, json: json),
      );

  ColumnDefinition<TestEntity, String> get testString =>
      ColumnDefinition<TestEntity, String>(
        'testString',
        write: (entity) => entity.testString,
        read: (json, entity, value) =>
            entity.copyWith(testString: CopyWith(value), json: json),
      );

  ColumnDefinition<TestEntity, String> get testUpgrade =>
      ColumnDefinition<TestEntity, String>(
        'testUpgrade',
        write: (entity) => entity.testUpgrade,
        read: (json, entity, value) =>
            entity.copyWith(testUpgrade: CopyWith(value), json: json),
      );

  ColumnDefinition<TestEntity, DateTime> get testDateTime =>
      ColumnDefinition<TestEntity, DateTime>(
        'testDateTime',
        write: (entity) => entity.testDateTime,
        read: (json, entity, value) =>
            entity.copyWith(testDateTime: CopyWith(value), json: json),
      );

  ColumnDefinition<TestEntity, int> get testInt =>
      ColumnDefinition<TestEntity, int>(
        'testInt',
        write: (entity) => entity.testInt,
        read: (json, entity, value) =>
            entity.copyWith(testInt: CopyWith(value), json: json),
      );

  ColumnDefinition<TestEntity, int> get testIntWithDefault =>
      ColumnDefinition<TestEntity, int>(
        'testIntWithDefault',
        write: (entity) => entity.testIntWithDefault,
        read: (json, entity, value) =>
            entity.copyWith(testIntWithDefault: CopyWith(value), json: json),
      );

  ColumnDefinition<TestEntity, bool> get testBool =>
      ColumnDefinition<TestEntity, bool>(
        'testBool',
        write: (entity) => entity.testBool,
        read: (json, entity, value) =>
            entity.copyWith(testBool: CopyWith(value), json: json),
      );

  ColumnDefinition<TestEntity, double> get testDouble =>
      ColumnDefinition<TestEntity, double>(
        'testDouble',
        write: (entity) => entity.testDouble,
        read: (json, entity, value) =>
            entity.copyWith(testDouble: CopyWith(value), json: json),
      );

  @override
  Iterable<ColumnDefinition<TestEntity, dynamic>> get columns => [
        id,
        createdAt,
        updatedAt,
        testString,
        testUpgrade,
        testDateTime,
        testInt,
        testIntWithDefault,
        testBool,
        testDouble,
      ];
}
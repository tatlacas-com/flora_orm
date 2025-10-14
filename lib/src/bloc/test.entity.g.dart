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
    String? collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ValueGetter<String?>? testString,
    ValueGetter<String?>? testUpgrade,
    ValueGetter<DateTime?>? testDateTime,
    ValueGetter<int?>? testInt,
    ValueGetter<int?>? testIntWithDefault,
    ValueGetter<bool?>? testBool,
    ValueGetter<double?>? testDouble,
    Map<String, dynamic>? json,
  }) {
    return TestEntity(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      testString: testString != null ? testString() : this.testString,
      testUpgrade: testUpgrade != null ? testUpgrade() : this.testUpgrade,
      testDateTime: testDateTime != null ? testDateTime() : this.testDateTime,
      testInt: testInt != null ? testInt() : this.testInt,
      testIntWithDefault: testIntWithDefault != null
          ? testIntWithDefault()
          : this.testIntWithDefault,
      testBool: testBool != null ? testBool() : this.testBool,
      testDouble: testDouble != null ? testDouble() : this.testDouble,
    );
  }
}
typedef TestEntityLocalDataSource
    = OrmEngine<TestEntity, TestEntityMeta, StoreContext<TestEntity>>;

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
        read: (json, entity, value) =>
            entity.copyWith(id: value as String?, json: json),
      );

  @override
  ColumnDefinition<TestEntity, String> get collectionId =>
      ColumnDefinition<TestEntity, String>(
        'collectionId',
        write: (entity) => entity.collectionId,
        read: (json, entity, value) =>
            entity.copyWith(collectionId: value as String?, json: json),
      );

  @override
  ColumnDefinition<TestEntity, DateTime> get createdAt =>
      ColumnDefinition<TestEntity, DateTime>(
        'createdAt',
        write: (entity) => entity.createdAt,
        read: (json, entity, value) =>
            entity.copyWith(createdAt: value as DateTime?, json: json),
      );

  @override
  ColumnDefinition<TestEntity, DateTime> get updatedAt =>
      ColumnDefinition<TestEntity, DateTime>(
        'updatedAt',
        write: (entity) => entity.updatedAt,
        read: (json, entity, value) =>
            entity.copyWith(updatedAt: value as DateTime?, json: json),
      );

  ColumnDefinition<TestEntity, String> get testString =>
      ColumnDefinition<TestEntity, String>(
        'testString',
        write: (entity) => entity.testString,
        read: (json, entity, value) => entity.copyWith(
          testString: () => value as String?,
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, String> get testUpgrade =>
      ColumnDefinition<TestEntity, String>(
        'testUpgrade',
        write: (entity) => entity.testUpgrade,
        read: (json, entity, value) => entity.copyWith(
          testUpgrade: () => value as String?,
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, DateTime> get testDateTime =>
      ColumnDefinition<TestEntity, DateTime>(
        'testDateTime',
        write: (entity) => entity.testDateTime,
        read: (json, entity, value) => entity.copyWith(
          testDateTime: () => value as DateTime?,
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, int> get testInt =>
      ColumnDefinition<TestEntity, int>(
        'testInt',
        write: (entity) => entity.testInt,
        read: (json, entity, value) => entity.copyWith(
          testInt: () => value as int?,
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, int> get testIntWithDefault =>
      ColumnDefinition<TestEntity, int>(
        'testIntWithDefault',
        write: (entity) => entity.testIntWithDefault,
        read: (json, entity, value) => entity.copyWith(
          testIntWithDefault: () => value as int?,
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, bool> get testBool =>
      ColumnDefinition<TestEntity, bool>(
        'testBool',
        write: (entity) => entity.testBool,
        read: (json, entity, value) => entity.copyWith(
          testBool: () => value as bool?,
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, double> get testDouble =>
      ColumnDefinition<TestEntity, double>(
        'testDouble',
        write: (entity) => entity.testDouble,
        read: (json, entity, value) => entity.copyWith(
          testDouble: () => value as double?,
          json: json,
        ),
      );

  @override
  Iterable<ColumnDefinition<TestEntity, dynamic>> get columns => [
        id,
        collectionId,
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

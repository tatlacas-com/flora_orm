// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test.entity.dart';

// **************************************************************************
// EntityPropsGenerator
// **************************************************************************

mixin _TestEntityMixin on Entity<TestEntity, TestEntityMeta> {
  static const TestEntityMeta _meta = TestEntityMeta();

  @override
  TestEntityMeta get meta => _meta;

  TestEntity readTestEnum1(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
          (element) => element?.name == value as String,
          orElse: () => null);
    }
    return copyWith(
      testEnum1: CopyWith(item),
    );
  }

  TestEntity readTestEnum2(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
          (element) => element?.name == value as String,
          orElse: () => null);
    }
    return copyWith(
      testEnum2: CopyWith(item),
    );
  }

  TestEntity readTestEnum3(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
          (element) => element?.name == value as String,
          orElse: () => null);
    }
    return copyWith(
      testEnum3: item,
    );
  }

  String? get testString;
  String? get testUpgrade;
  DateTime? get testDateTime;
  int? get testInt;
  double get testDouble2;
  int? get testIntWithDefault;
  bool? get testBool;
  double? get testDouble;
  TestEnum? get testEnum1;
  TestEnum? get testEnum2;
  TestEnum get testEnum3;

  @override
  List<Object?> get props => [
        ...super.props,
        testString,
        testUpgrade,
        testDateTime,
        testInt,
        testDouble2,
        testIntWithDefault,
        testBool,
        testDouble,
        testEnum1,
        testEnum2,
        testEnum3,
      ];
  @override
  TestEntity copyWith({
    String? id,
    String? collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    CopyWith<String?>? testString,
    CopyWith<String?>? testUpgrade,
    CopyWith<DateTime?>? testDateTime,
    CopyWith<int?>? testInt,
    double? testDouble2,
    CopyWith<int?>? testIntWithDefault,
    CopyWith<bool?>? testBool,
    CopyWith<double?>? testDouble,
    CopyWith<TestEnum?>? testEnum1,
    CopyWith<TestEnum?>? testEnum2,
    TestEnum? testEnum3,
    Map<String, dynamic>? json,
  }) {
    return TestEntity(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      testString: testString != null ? testString.value : this.testString,
      testUpgrade: testUpgrade != null ? testUpgrade.value : this.testUpgrade,
      testDateTime:
          testDateTime != null ? testDateTime.value : this.testDateTime,
      testInt: testInt != null ? testInt.value : this.testInt,
      testDouble2: testDouble2 ?? this.testDouble2,
      testIntWithDefault: testIntWithDefault != null
          ? testIntWithDefault.value
          : this.testIntWithDefault,
      testBool: testBool != null ? testBool.value : this.testBool,
      testDouble: testDouble != null ? testDouble.value : this.testDouble,
      testEnum1: testEnum1 != null ? testEnum1.value : this.testEnum1,
      testEnum2: testEnum2 != null ? testEnum2.value : this.testEnum2,
      testEnum3: testEnum3 ?? this.testEnum3,
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
          testString: CopyWith(value as String?),
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, String> get testUpgrade =>
      ColumnDefinition<TestEntity, String>(
        'testUpgrade',
        write: (entity) => entity.testUpgrade,
        read: (json, entity, value) => entity.copyWith(
          testUpgrade: CopyWith(value as String?),
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, DateTime> get testDateTime =>
      ColumnDefinition<TestEntity, DateTime>(
        'testDateTime',
        write: (entity) => entity.testDateTime,
        read: (json, entity, value) => entity.copyWith(
          testDateTime: CopyWith(value as DateTime?),
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, int> get testInt =>
      ColumnDefinition<TestEntity, int>(
        'testInt',
        write: (entity) => entity.testInt,
        read: (json, entity, value) => entity.copyWith(
          testInt: CopyWith(value as int?),
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, double> get testDouble2 =>
      ColumnDefinition<TestEntity, double>(
        'testDouble2',
        notNull: true,
        defaultValue: 10,
        write: (entity) => entity.testDouble2,
        read: (json, entity, value) => entity.copyWith(
          testDouble2: value as double?,
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, int> get testIntWithDefault =>
      ColumnDefinition<TestEntity, int>(
        'testIntWithDefault',
        write: (entity) => entity.testIntWithDefault,
        read: (json, entity, value) => entity.copyWith(
          testIntWithDefault: CopyWith(value as int?),
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, bool> get testBool =>
      ColumnDefinition<TestEntity, bool>(
        'testBool',
        write: (entity) => entity.testBool,
        read: (json, entity, value) => entity.copyWith(
          testBool: CopyWith(value as bool?),
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, double> get testDouble =>
      ColumnDefinition<TestEntity, double>(
        'testDouble',
        write: (entity) => entity.testDouble,
        read: (json, entity, value) => entity.copyWith(
          testDouble: CopyWith(value as double?),
          json: json,
        ),
      );

  ColumnDefinition<TestEntity, String> get testEnum1 =>
      ColumnDefinition<TestEntity, String>(
        'testEnum1',
        write: (entity) {
          if (entity.testEnum1 == null) {
            return null;
          }
          final map = entity.testEnum1?.name;

          return map;
        },
        read: (json, entity, value) {
          return entity.readTestEnum1(json, value);
        },
      );

  ColumnDefinition<TestEntity, String> get testEnum2 =>
      ColumnDefinition<TestEntity, String>(
        'testEnum2',
        defaultValue: 'value1',
        write: (entity) {
          if (entity.testEnum2 == null) {
            return null;
          }
          final map = entity.testEnum2?.name;

          return map;
        },
        read: (json, entity, value) {
          return entity.readTestEnum2(json, value);
        },
      );

  ColumnDefinition<TestEntity, String> get testEnum3 =>
      ColumnDefinition<TestEntity, String>(
        'testEnum3',
        notNull: true,
        defaultValue: 'value1',
        write: (entity) {
          final map = entity.testEnum3.name;

          return map;
        },
        read: (json, entity, value) {
          return entity.readTestEnum3(json, value);
        },
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
        testDouble2,
        testIntWithDefault,
        testBool,
        testDouble,
        testEnum1,
        testEnum2,
        testEnum3,
      ];
}

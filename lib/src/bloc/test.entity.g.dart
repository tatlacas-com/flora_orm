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
      testEnum1: () => item,
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
      testEnum2: () => item,
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

  TestEntity readIntList(Map<String, dynamic> json, dynamic value) {
    List<int>? items;
    if (value != null) {
      final list = value is List ? value : jsonDecode(value as String);
      items = (list as List<dynamic>?)?.map<int>((e) => e as int).toList();
    }
    return copyWith(
      intList: items,
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
  List<int> get intList;

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
        intList,
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
    double? testDouble2,
    ValueGetter<int?>? testIntWithDefault,
    ValueGetter<bool?>? testBool,
    ValueGetter<double?>? testDouble,
    ValueGetter<TestEnum?>? testEnum1,
    ValueGetter<TestEnum?>? testEnum2,
    TestEnum? testEnum3,
    List<int>? intList,
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
      testDouble2: testDouble2 ?? this.testDouble2,
      testIntWithDefault: testIntWithDefault != null
          ? testIntWithDefault()
          : this.testIntWithDefault,
      testBool: testBool != null ? testBool() : this.testBool,
      testDouble: testDouble != null ? testDouble() : this.testDouble,
      testEnum1: testEnum1 != null ? testEnum1() : this.testEnum1,
      testEnum2: testEnum2 != null ? testEnum2() : this.testEnum2,
      testEnum3: testEnum3 ?? this.testEnum3,
      intList: intList ?? this.intList,
    );
  }
}
typedef TestEntityStore
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

  ColumnDefinition<TestEntity, String> get testEnum1 =>
      ColumnDefinition<TestEntity, String>(
        'testEnum1',
        write: (entity) {
          final testEnum1 = entity.testEnum1;

          if (testEnum1 == null) {
            return null;
          } else if (testEnum1.isEmpty) {
            return '';
          }
          final map = testEnum1?.name;

          return map;
        },
        read: (json, entity, value) {},
      );

  ColumnDefinition<TestEntity, String> get testEnum2 =>
      ColumnDefinition<TestEntity, String>(
        'testEnum2',
        defaultValue: 'value1',
        write: (entity) {
          final testEnum2 = entity.testEnum2;

          if (testEnum2 == null) {
            return null;
          } else if (testEnum2.isEmpty) {
            return '';
          }
          final map = testEnum2?.name;

          return map;
        },
        read: (json, entity, value) {},
      );

  ColumnDefinition<TestEntity, String> get testEnum3 =>
      ColumnDefinition<TestEntity, String>(
        'testEnum3',
        notNull: true,
        defaultValue: 'value1',
        write: (entity) {
          final testEnum3 = entity.testEnum3;

          final map = testEnum3.name;

          return map;
        },
        read: (json, entity, value) {},
      );

  ColumnDefinition<TestEntity, String> get intList =>
      ColumnDefinition<TestEntity, String>(
        'intList',
        notNull: true,
        write: (entity) {
          final map = entity.intList.map((p) => p).toList();

          return jsonEncode(map);
        },
        read: (json, entity, value) {
          if (value == '') {
            value = '[]';
          }
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
        intList,
      ];
}

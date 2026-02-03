// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_model.dart';

// **************************************************************************
// ModelPropsGenerator
// **************************************************************************

mixin _TestModelMixin on Model<TestModel, TestModelMeta> {
  static const TestModelMeta _meta = TestModelMeta();

  @override
  TestModelMeta get meta => _meta;

  TestModel readTestEnum1(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
        (element) => element?.name == value as String,
        orElse: () => null,
      );
    }
    return copyWith(testEnum1: () => item);
  }

  TestModel readTestEnum2(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
        (element) => element?.name == value as String,
        orElse: () => null,
      );
    }
    return copyWith(testEnum2: () => item);
  }

  TestModel readTestEnum3(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
        (element) => element?.name == value as String,
        orElse: () => null,
      );
    }
    return copyWith(testEnum3: item);
  }

  TestModel readIntList(Map<String, dynamic> json, dynamic value) {
    List<int>? items;
    if (value != null) {
      final list = value is List ? value : jsonDecode(value as String);
      items = (list as List<dynamic>?)?.map<int>((e) => e as int).toList();
    }
    return copyWith(intList: items);
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
  TestModel copyWith({
    String? id,
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
    return TestModel(
      id: id ?? this.id,
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
typedef TestModelStore =
    OrmEngine<TestModel, TestModelMeta, StoreContext<TestModel>>;

class TestModelMeta extends ModelMeta<TestModel> {
  const TestModelMeta();

  @override
  String get tableName => 'test';

  @override
  ColumnDefinition<TestModel, String> get id =>
      ColumnDefinition<TestModel, String>(
        'id',
        primaryKey: true,
        write: (model) => model.id,
        read: (json, model, value) =>
            model.copyWith(id: value as String?, json: json),
      );

  @override
  ColumnDefinition<TestModel, DateTime> get createdAt =>
      ColumnDefinition<TestModel, DateTime>(
        'createdAt',
        write: (model) => model.createdAt,
        read: (json, model, value) =>
            model.copyWith(createdAt: value as DateTime?, json: json),
      );

  @override
  ColumnDefinition<TestModel, DateTime> get updatedAt =>
      ColumnDefinition<TestModel, DateTime>(
        'updatedAt',
        write: (model) => model.updatedAt,
        read: (json, model, value) =>
            model.copyWith(updatedAt: value as DateTime?, json: json),
      );

  ColumnDefinition<TestModel, String> get testString =>
      ColumnDefinition<TestModel, String>(
        'testString',

        write: (model) => model.testString,

        read: (json, model, value) =>
            model.copyWith(testString: () => value as String?, json: json),
      );

  ColumnDefinition<TestModel, String> get testUpgrade =>
      ColumnDefinition<TestModel, String>(
        'testUpgrade',

        write: (model) => model.testUpgrade,

        read: (json, model, value) =>
            model.copyWith(testUpgrade: () => value as String?, json: json),
      );

  ColumnDefinition<TestModel, DateTime> get testDateTime =>
      ColumnDefinition<TestModel, DateTime>(
        'testDateTime',

        write: (model) => model.testDateTime,

        read: (json, model, value) =>
            model.copyWith(testDateTime: () => value as DateTime?, json: json),
      );

  ColumnDefinition<TestModel, int> get testInt =>
      ColumnDefinition<TestModel, int>(
        'testInt',

        write: (model) => model.testInt,

        read: (json, model, value) =>
            model.copyWith(testInt: () => value as int?, json: json),
      );

  ColumnDefinition<TestModel, double> get testDouble2 =>
      ColumnDefinition<TestModel, double>(
        'testDouble2',

        notNull: true,

        defaultValue: 10,

        write: (model) => model.testDouble2,

        read: (json, model, value) =>
            model.copyWith(testDouble2: value as double?, json: json),
      );

  ColumnDefinition<TestModel, int> get testIntWithDefault =>
      ColumnDefinition<TestModel, int>(
        'testIntWithDefault',

        write: (model) => model.testIntWithDefault,

        read: (json, model, value) =>
            model.copyWith(testIntWithDefault: () => value as int?, json: json),
      );

  ColumnDefinition<TestModel, bool> get testBool =>
      ColumnDefinition<TestModel, bool>(
        'testBool',

        write: (model) => model.testBool,

        read: (json, model, value) =>
            model.copyWith(testBool: () => value as bool?, json: json),
      );

  ColumnDefinition<TestModel, double> get testDouble =>
      ColumnDefinition<TestModel, double>(
        'testDouble',

        write: (model) => model.testDouble,

        read: (json, model, value) =>
            model.copyWith(testDouble: () => value as double?, json: json),
      );

  ColumnDefinition<TestModel, String> get testEnum1 =>
      ColumnDefinition<TestModel, String>(
        'testEnum1',

        write: (model) {
          final testEnum1 = model.testEnum1;

          if (testEnum1 == null) {
            return null;
          }
          final map = testEnum1.name;

          return map;
        },

        read: (json, model, value) {
          return model.readTestEnum1(json, value);
        },
      );

  ColumnDefinition<TestModel, String> get testEnum2 =>
      ColumnDefinition<TestModel, String>(
        'testEnum2',

        defaultValue: 'value1',

        write: (model) {
          final testEnum2 = model.testEnum2;

          if (testEnum2 == null) {
            return null;
          }
          final map = testEnum2.name;

          return map;
        },

        read: (json, model, value) {
          return model.readTestEnum2(json, value);
        },
      );

  ColumnDefinition<TestModel, String> get testEnum3 =>
      ColumnDefinition<TestModel, String>(
        'testEnum3',

        notNull: true,

        defaultValue: 'value1',

        write: (model) {
          final testEnum3 = model.testEnum3;

          final map = testEnum3.name;

          return map;
        },

        read: (json, model, value) {
          return model.readTestEnum3(json, value);
        },
      );

  ColumnDefinition<TestModel, String> get intList =>
      ColumnDefinition<TestModel, String>(
        'intList',

        notNull: true,

        write: (model) {
          final intList = model.intList;

          if (intList.isEmpty) {
            return '';
          }

          final map = intList.map((p) => p).toList();

          return jsonEncode(map);
        },

        read: (json, model, value) {
          if (value == '') {
            value = '[]';
          }

          return model.readIntList(json, value);
        },
      );

  @override
  Iterable<ColumnDefinition<TestModel, dynamic>> get columns => [
    id,
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

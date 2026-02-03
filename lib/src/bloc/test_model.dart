import 'package:flora_orm/flora_orm.dart';

part 'test_model.g.dart';
part 'test_model.migrations.dart';

@OrmModel(tableName: 'test')
class TestModel extends Model<TestModel, TestModelMeta>
    with _TestModelMixin, TestModelMigrations {
  const TestModel({
    super.id,
    super.restorationId,
    super.createdAt,
    super.updatedAt,
    this.testString,
    this.testUpgrade,
    this.testDateTime,
    this.testInt,
    this.testIntWithDefault,
    this.testBool,
    this.testDouble,
    this.testEnum1,
    this.testEnum2,
    this.intList = const [],
    this.testEnum3 = TestEnum.value1,
    this.testDouble2 = 10,
  });
  @override
  @column
  final String? testString;
  @override
  @column
  final String? testUpgrade;
  @override
  @column
  final DateTime? testDateTime;
  @override
  @column
  final int? testInt;
  @override
  @OrmColumn<double>(defaultValue: 10)
  final double testDouble2;
  @override
  @column
  final int? testIntWithDefault;
  @override
  @column
  final bool? testBool;
  @override
  @column
  final double? testDouble;
  @override
  @column
  final TestEnum? testEnum1;
  @override
  @OrmColumn<TestEnum>(defaultValue: 'value1')
  final TestEnum? testEnum2;
  @override
  @OrmColumn<TestEnum>(defaultValue: 'value1')
  final TestEnum testEnum3;

  @override
  @column
  final List<int> intList;
}

enum TestEnum { value1, value2 }

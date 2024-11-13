import 'package:flora_orm/flora_orm.dart';

part 'test.entity.g.dart';
part 'test.entity.migrations.dart';

@OrmEntity(tableName: 'test')
class TestEntity extends Entity<TestEntity, TestEntityMeta>
    with _TestEntityMixin, TestEntityMigrations {
  const TestEntity({
    super.id,
    super.collectionId,
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
  @column
  final int? testIntWithDefault;
  @override
  @column
  final bool? testBool;
  @override
  @column
  final double? testDouble;
}

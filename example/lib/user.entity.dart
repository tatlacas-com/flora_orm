import 'package:example/test_enum.dart';
import 'package:flora_orm/flora_orm.dart';
part 'user.entity.g.dart';
part 'user.entity.migrations.dart';

@OrmEntity(tableName: 'user')
class UserEntity extends Entity<UserEntity, UserEntityMeta>
    with _UserEntityMixin, UserEntityMigrations {
  UserEntity(
      {super.id,
      super.collectionId,
      super.createdAt,
      super.updatedAt,
      this.firstName,
      this.lastName,
      this.testEnum,
      this.testEnum2 = TestEnum.first,
      this.test2,
      this.reactionsCounts = const {}}) {
    test = '';
  }

  @override
  @column
  final String? firstName;
  @override
  @column
  final String? lastName;
  @override
  @column
  final TestEnum? testEnum;
  @override
  @OrmColumn(defaultValue: 'first')
  final TestEnum testEnum2;

  late final String? test;
  @override
  final String? test2;

  @override
  @column
  final Map<String, int> reactionsCounts;
}

import 'package:example/test_enum.dart';
import 'package:flora_orm/flora_orm.dart';
part 'user_model.g.dart';
part 'user_model.migrations.dart';

abstract class BaseUser<
  TModel extends ModelBase,
  TMeta extends ModelMeta<TModel>
>
    extends Model<TModel, TMeta> {
  const BaseUser({
    super.id,
    super.collectionId,
    super.createdAt,
    super.updatedAt,
    this.firstName,
    this.lastName,
  });
  @column
  final String? firstName;
  @column
  final String? lastName;
}

@OrmModel(tableName: 'user')
class UserModel extends BaseUser<UserModel, UserModelMeta>
    with _UserModelMixin, UserModelMigrations {
  UserModel({
    super.id,
    super.collectionId,
    super.createdAt,
    super.updatedAt,
    super.firstName,
    super.lastName,
    this.testEnum,
    this.testEnum2 = TestEnum.first,
    this.test2,
    this.reactionsCounts = const {},
  }) {
    test = '';
  }

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

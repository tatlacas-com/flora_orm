import 'package:example/copy_with.dart';
import 'package:flora_orm/flora_orm.dart';
part 'user.entity.g.dart';

@OrmEntity(tableName: 'user')
class UserEntity extends Entity<UserEntity, UserEntityMeta>
    with _UserEntityMixin {
  @override
  @column
  final String? firstName;
  @override
  @column
  final String? lastName;

  const UserEntity({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.firstName,
    this.lastName,
  });
}

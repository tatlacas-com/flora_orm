// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.entity.dart';

// **************************************************************************
// EntityPropsGenerator
// **************************************************************************

mixin _UserEntityMixin on Entity<UserEntity, UserEntityMeta> {
  static const UserEntityMeta _meta = UserEntityMeta();

  @override
  UserEntityMeta get meta => _meta;

  UserEntity readTestEnum(Map<String, dynamic> json, value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
          (element) => element?.name == value as String,
          orElse: () => null);
    }
    return copyWith(
      testEnum: CopyWith(item),
    );
  }

  String? get firstName;
  String? get lastName;
  TestEnum? get testEnum;

  @override
  List<Object?> get props => [
        ...super.props,
        firstName,
        lastName,
        testEnum,
      ];
  @override
  UserEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    CopyWith<String?>? firstName,
    CopyWith<String?>? lastName,
    CopyWith<TestEnum?>? testEnum,
    Map<String, dynamic>? json,
  }) {
    return UserEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName != null ? firstName.value : this.firstName,
      lastName: lastName != null ? lastName.value : this.lastName,
      testEnum: testEnum != null ? testEnum.value : this.testEnum,
    );
  }
}
typedef UserEntityOrm
    = OrmEngine<UserEntity, UserEntityMeta, DbContext<UserEntity>>;

class UserEntityMeta extends EntityMeta<UserEntity> {
  const UserEntityMeta();

  @override
  String get tableName => 'user';

  @override
  ColumnDefinition<UserEntity, String> get id =>
      ColumnDefinition<UserEntity, String>(
        'id',
        primaryKey: true,
        write: (entity) => entity.id,
        read: (json, entity, value) => entity.copyWith(id: value, json: json),
      );

  @override
  ColumnDefinition<UserEntity, DateTime> get createdAt =>
      ColumnDefinition<UserEntity, DateTime>(
        'createdAt',
        write: (entity) => entity.createdAt,
        read: (json, entity, value) =>
            entity.copyWith(createdAt: value, json: json),
      );

  @override
  ColumnDefinition<UserEntity, DateTime> get updatedAt =>
      ColumnDefinition<UserEntity, DateTime>(
        'updatedAt',
        write: (entity) => entity.updatedAt,
        read: (json, entity, value) =>
            entity.copyWith(updatedAt: value, json: json),
      );

  ColumnDefinition<UserEntity, String> get firstName =>
      ColumnDefinition<UserEntity, String>(
        'firstName',
        write: (entity) => entity.firstName,
        read: (json, entity, value) =>
            entity.copyWith(firstName: CopyWith(value), json: json),
      );

  ColumnDefinition<UserEntity, String> get lastName =>
      ColumnDefinition<UserEntity, String>(
        'lastName',
        write: (entity) => entity.lastName,
        read: (json, entity, value) =>
            entity.copyWith(lastName: CopyWith(value), json: json),
      );

  ColumnDefinition<UserEntity, String> get testEnum =>
      ColumnDefinition<UserEntity, String>(
        'testEnum',
        write: (entity) {
          if (entity.testEnum == null) {
            return null;
          }
          final map = entity.testEnum?.name;

          return map;
        },
        read: (json, entity, value) {
          return entity.readTestEnum(json, value);
        },
      );

  @override
  Iterable<ColumnDefinition<UserEntity, dynamic>> get columns => [
        id,
        createdAt,
        updatedAt,
        firstName,
        lastName,
        testEnum,
      ];
}

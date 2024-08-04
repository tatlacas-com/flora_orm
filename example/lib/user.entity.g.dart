// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.entity.dart';

// **************************************************************************
// DbColumnGenerator
// **************************************************************************

mixin _UserEntityMixin on Entity<UserEntity, UserEntityMeta> {
  static const UserEntityMeta _meta = UserEntityMeta();

  @override
  UserEntityMeta get meta => _meta;

  String? get firstName;
  String? get lastName;

  @override
  List<Object?> get props => [
        ...super.props,
        firstName,
        lastName,
      ];
  @override
  UserEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    CopyWith<String?>? firstName,
    CopyWith<String?>? lastName,
    Map<String, dynamic>? json,
  }) {
    return UserEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      firstName: firstName != null ? firstName.value : this.firstName,
      lastName: lastName != null ? lastName.value : this.lastName,
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

  @override
  Iterable<ColumnDefinition<UserEntity, dynamic>> get columns => [
        id,
        createdAt,
        updatedAt,
        firstName,
        lastName,
      ];
}

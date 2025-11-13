// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.entity.dart';

// **************************************************************************
// EntityPropsGenerator
// **************************************************************************

mixin _UserEntityMixin on Entity<UserEntity, UserEntityMeta> {
  static const UserEntityMeta _meta = UserEntityMeta();

  @override
  UserEntityMeta get meta => _meta;

  UserEntity readTestEnum(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
          (element) => element?.name == value as String,
          orElse: () => null);
    }
    return copyWith(
      testEnum: () => item,
    );
  }

  UserEntity readTestEnum2(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
          (element) => element?.name == value as String,
          orElse: () => null);
    }
    return copyWith(
      testEnum2: item,
    );
  }

  UserEntity readReactionsCounts(Map<String, dynamic> json, dynamic value) {
    Map<String, int>? item;
    if (value != null) {
      final map =
          value is Map<String, dynamic> ? value : jsonDecode(value as String);
      item = map.cast<String, int>();
    }
    return copyWith(
      reactionsCounts: item,
    );
  }

  TestEnum? get testEnum;
  TestEnum get testEnum2;
  Map<String, int> get reactionsCounts;
  String? get firstName;
  String? get lastName;
  String? get test2;

  @override
  List<Object?> get props => [
        ...super.props,
        testEnum,
        testEnum2,
        reactionsCounts,
        firstName,
        lastName,
        test2,
      ];
  @override
  UserEntity copyWith({
    String? id,
    String? collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    ValueGetter<TestEnum?>? testEnum,
    TestEnum? testEnum2,
    Map<String, int>? reactionsCounts,
    ValueGetter<String?>? firstName,
    ValueGetter<String?>? lastName,
    ValueGetter<String?>? test2,
    Map<String, dynamic>? json,
  }) {
    return UserEntity(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      testEnum: testEnum != null ? testEnum() : this.testEnum,
      testEnum2: testEnum2 ?? this.testEnum2,
      reactionsCounts: reactionsCounts ?? this.reactionsCounts,
      firstName: firstName != null ? firstName() : this.firstName,
      lastName: lastName != null ? lastName() : this.lastName,
      test2: test2 != null ? test2() : this.test2,
    );
  }
}
typedef UserEntityStore
    = OrmEngine<UserEntity, UserEntityMeta, StoreContext<UserEntity>>;

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
        read: (json, entity, value) =>
            entity.copyWith(id: value as String?, json: json),
      );

  @override
  ColumnDefinition<UserEntity, String> get collectionId =>
      ColumnDefinition<UserEntity, String>(
        'collectionId',
        write: (entity) => entity.collectionId,
        read: (json, entity, value) =>
            entity.copyWith(collectionId: value as String?, json: json),
      );

  @override
  ColumnDefinition<UserEntity, DateTime> get createdAt =>
      ColumnDefinition<UserEntity, DateTime>(
        'createdAt',
        write: (entity) => entity.createdAt,
        read: (json, entity, value) =>
            entity.copyWith(createdAt: value as DateTime?, json: json),
      );

  @override
  ColumnDefinition<UserEntity, DateTime> get updatedAt =>
      ColumnDefinition<UserEntity, DateTime>(
        'updatedAt',
        write: (entity) => entity.updatedAt,
        read: (json, entity, value) =>
            entity.copyWith(updatedAt: value as DateTime?, json: json),
      );

  ColumnDefinition<UserEntity, String> get testEnum =>
      ColumnDefinition<UserEntity, String>(
        'testEnum',
        write: (entity) {
          final testEnum = entity.testEnum;

          if (testEnum == null) {
            return null;
          } else if (testEnum.isEmpty) {
            return '';
          }
          final map = testEnum?.name;

          return map;
        },
        read: (json, entity, value) {},
      );

  ColumnDefinition<UserEntity, String> get testEnum2 =>
      ColumnDefinition<UserEntity, String>(
        'testEnum2',
        notNull: true,
        defaultValue: 'first',
        write: (entity) {
          final testEnum2 = entity.testEnum2;

          final map = testEnum2.name;

          return map;
        },
        read: (json, entity, value) {},
      );

  ColumnDefinition<UserEntity, String> get reactionsCounts =>
      ColumnDefinition<UserEntity, String>(
        'reactionsCounts',
        notNull: true,
        write: (entity) {
          final reactionsCounts = entity.reactionsCounts;

          final map = reactionsCounts;

          return jsonEncode(map);
        },
        read: (json, entity, value) {},
      );

  ColumnDefinition<UserEntity, String> get firstName =>
      ColumnDefinition<UserEntity, String>(
        'firstName',
        write: (entity) => entity.firstName,
        read: (json, entity, value) => entity.copyWith(
          firstName: () => value as String?,
          json: json,
        ),
      );

  ColumnDefinition<UserEntity, String> get lastName =>
      ColumnDefinition<UserEntity, String>(
        'lastName',
        write: (entity) => entity.lastName,
        read: (json, entity, value) => entity.copyWith(
          lastName: () => value as String?,
          json: json,
        ),
      );

  @override
  Iterable<ColumnDefinition<UserEntity, dynamic>> get columns => [
        id,
        collectionId,
        createdAt,
        updatedAt,
        testEnum,
        testEnum2,
        reactionsCounts,
        firstName,
        lastName,
      ];
}

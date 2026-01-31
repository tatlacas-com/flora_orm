// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// ModelPropsGenerator
// **************************************************************************

mixin _UserModelMixin on Model<UserModel, UserModelMeta> {
  static const UserModelMeta _meta = UserModelMeta();

  @override
  UserModelMeta get meta => _meta;

  UserModel readTestEnum(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
        (element) => element?.name == value as String,
        orElse: () => null,
      );
    }
    return copyWith(testEnum: () => item);
  }

  UserModel readTestEnum2(Map<String, dynamic> json, dynamic value) {
    TestEnum? item;
    if (value != null) {
      item = <TestEnum?>[...TestEnum.values].firstWhere(
        (element) => element?.name == value as String,
        orElse: () => null,
      );
    }
    return copyWith(testEnum2: item);
  }

  UserModel readReactionsCounts(Map<String, dynamic> json, dynamic value) {
    Map<String, int>? item;
    if (value != null) {
      final map = value is Map<String, dynamic>
          ? value
          : jsonDecode(value as String);
      item = map.cast<String, int>();
    }
    return copyWith(reactionsCounts: item);
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
  UserModel copyWith({
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
    return UserModel(
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
typedef UserModelStore =
    OrmEngine<UserModel, UserModelMeta, StoreContext<UserModel>>;

class UserModelMeta extends ModelMeta<UserModel> {
  const UserModelMeta();

  @override
  String get tableName => 'user';

  @override
  ColumnDefinition<UserModel, String> get id =>
      ColumnDefinition<UserModel, String>(
        'id',
        primaryKey: true,
        write: (model) => model.id,
        read: (json, model, value) =>
            model.copyWith(id: value as String?, json: json),
      );

  @override
  ColumnDefinition<UserModel, String> get collectionId =>
      ColumnDefinition<UserModel, String>(
        'collectionId',
        write: (model) => model.collectionId,
        read: (json, model, value) =>
            model.copyWith(collectionId: value as String?, json: json),
      );

  @override
  ColumnDefinition<UserModel, DateTime> get createdAt =>
      ColumnDefinition<UserModel, DateTime>(
        'createdAt',
        write: (model) => model.createdAt,
        read: (json, model, value) =>
            model.copyWith(createdAt: value as DateTime?, json: json),
      );

  @override
  ColumnDefinition<UserModel, DateTime> get updatedAt =>
      ColumnDefinition<UserModel, DateTime>(
        'updatedAt',
        write: (model) => model.updatedAt,
        read: (json, model, value) =>
            model.copyWith(updatedAt: value as DateTime?, json: json),
      );

  ColumnDefinition<UserModel, String> get testEnum =>
      ColumnDefinition<UserModel, String>(
        'testEnum',

        write: (model) {
          final testEnum = model.testEnum;

          if (testEnum == null) {
            return null;
          }
          final map = testEnum.name;

          return map;
        },

        read: (json, model, value) {
          return model.readTestEnum(json, value);
        },
      );

  ColumnDefinition<UserModel, String> get testEnum2 =>
      ColumnDefinition<UserModel, String>(
        'testEnum2',

        notNull: true,

        defaultValue: 'first',

        write: (model) {
          final testEnum2 = model.testEnum2;

          final map = testEnum2.name;

          return map;
        },

        read: (json, model, value) {
          return model.readTestEnum2(json, value);
        },
      );

  ColumnDefinition<UserModel, String> get reactionsCounts =>
      ColumnDefinition<UserModel, String>(
        'reactionsCounts',

        notNull: true,

        write: (model) {
          final reactionsCounts = model.reactionsCounts;

          final map = reactionsCounts;

          return jsonEncode(map);
        },

        read: (json, model, value) {
          return model.readReactionsCounts(json, value);
        },
      );

  ColumnDefinition<UserModel, String> get firstName =>
      ColumnDefinition<UserModel, String>(
        'firstName',

        write: (model) => model.firstName,

        read: (json, model, value) =>
            model.copyWith(firstName: () => value as String?, json: json),
      );

  ColumnDefinition<UserModel, String> get lastName =>
      ColumnDefinition<UserModel, String>(
        'lastName',

        write: (model) => model.lastName,

        read: (json, model, value) =>
            model.copyWith(lastName: () => value as String?, json: json),
      );

  @override
  Iterable<ColumnDefinition<UserModel, dynamic>> get columns => [
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

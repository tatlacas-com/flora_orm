// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal.entity.dart';

// **************************************************************************
// DbColumnGenerator
// **************************************************************************

mixin _AnimalEntityMixin on Entity<AnimalEntity, AnimalEntityMeta> {
  static const AnimalEntityMeta _meta = AnimalEntityMeta();

  @override
  AnimalEntityMeta get meta => _meta;

  AnimalEntity readTesting(Map<String, dynamic> json, value) {
    Testing? item;
    if (value != null) {
      Map<String, dynamic> map = jsonDecode(value);
      item = Testing.fromMap(map);
    }
    return copyWith(
      testing: CopyWith(item),
    );
  }

  AnimalEntity readTesting2(Map<String, dynamic> json, value) {
    List<Testing>? items;
    if (value != null) {
      List<dynamic> map = jsonDecode(value);
      items = map.map<Testing>((e) => Testing.fromMap(e)).toList();
    }
    return copyWith(
      testing2: CopyWith(items),
    );
  }

  String? get text;
  Testing? get testing;
  List<Testing>? get testing2;

  @override
  List<Object?> get props => [
        ...super.props,
        text,
        testing,
        testing2,
      ];
  @override
  AnimalEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    CopyWith<String?>? text,
    CopyWith<Testing?>? testing,
    CopyWith<List<Testing>?>? testing2,
    Map<String, dynamic>? json,
  }) {
    return AnimalEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      text: text != null ? text.value : this.text,
      testing: testing != null ? testing.value : this.testing,
      testing2: testing2 != null ? testing2.value : this.testing2,
    );
  }
}
typedef AnimalEntityOrm
    = OrmEngine<AnimalEntity, AnimalEntityMeta, DbContext<AnimalEntity>>;

class AnimalEntityMeta extends EntityMeta<AnimalEntity> {
  const AnimalEntityMeta();

  @override
  String get tableName => 'animal_entity';

  @override
  ColumnDefinition<AnimalEntity, String> get id =>
      ColumnDefinition<AnimalEntity, String>(
        'id',
        primaryKey: true,
        write: (entity) => entity.id,
        read: (json, entity, value) => entity.copyWith(id: value, json: json),
      );

  @override
  ColumnDefinition<AnimalEntity, DateTime> get createdAt =>
      ColumnDefinition<AnimalEntity, DateTime>(
        'createdAt',
        write: (entity) => entity.createdAt,
        read: (json, entity, value) =>
            entity.copyWith(createdAt: value, json: json),
      );

  @override
  ColumnDefinition<AnimalEntity, DateTime> get updatedAt =>
      ColumnDefinition<AnimalEntity, DateTime>(
        'updatedAt',
        write: (entity) => entity.updatedAt,
        read: (json, entity, value) =>
            entity.copyWith(updatedAt: value, json: json),
      );

  ColumnDefinition<AnimalEntity, String> get text =>
      ColumnDefinition<AnimalEntity, String>(
        'text',
        write: (entity) => entity.text,
        read: (json, entity, value) =>
            entity.copyWith(text: CopyWith(value), json: json),
      );

  ColumnDefinition<AnimalEntity, String> get testing =>
      ColumnDefinition<AnimalEntity, String>(
        'testing',
        write: (entity) {
          if (entity.testing == null) {
            return null;
          }
          final map = entity.testing?.toMap();

          return jsonEncode(map);
        },
        read: (json, entity, value) {
          if ('null' == value) {
            return entity.readTesting(json, null);
          }
          return entity.readTesting(json, value);
        },
      );

  ColumnDefinition<AnimalEntity, String> get testing2 =>
      ColumnDefinition<AnimalEntity, String>(
        'testing2',
        write: (entity) {
          final map = entity.testing2?.map((p) => p.toMap()).toList();

          return jsonEncode(map);
        },
        read: (json, entity, value) {
          if ('null' == value) {
            return entity.readTesting2(json, null);
          }
          return entity.readTesting2(json, value);
        },
      );

  @override
  Iterable<ColumnDefinition<AnimalEntity, dynamic>> get columns => [
        id,
        createdAt,
        updatedAt,
        text,
        testing,
        testing2,
      ];
}

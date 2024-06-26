// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal.entity.dart';

// **************************************************************************
// DbColumnGenerator
// **************************************************************************

mixin _AnimalEntityMixin on Entity<AnimalEntity, AnimalEntityMeta> {
  static const AnimalEntityMeta _meta = AnimalEntityMeta();

  @override
  AnimalEntityMeta get meta => _meta;

  AnimalEntity readList(Map<String, dynamic> json, value) {
    List<String>? items;
    if (value != null) {
      List<dynamic> map = value is List ? value : jsonDecode(value);
      items = map.map<String>((e) => e as String).toList();
    }
    return copyWith(
      list: CopyWith(items),
    );
  }

  AnimalEntity readDt(Map<String, dynamic> json, value) {
    List<DateTime>? items;
    if (value != null) {
      List<dynamic> map = value is List ? value : jsonDecode(value);
      items = map.map<DateTime>((e) => DateTime.parse(e as String)).toList();
    }
    return copyWith(
      dt: CopyWith(items),
    );
  }

  AnimalEntity readNumnum(Map<String, dynamic> json, value) {
    Menum? item;
    if (value != null) {
      item =
          Menum.values.firstWhere((element) => element.name == value as String);
    }
    return copyWith(
      numnum: CopyWith(item),
    );
  }

  AnimalEntity readNum4(Map<String, dynamic> json, value) {
    Menum? item;
    if (value != null) {
      item =
          Menum.values.firstWhere((element) => element.name == value as String);
    }
    return copyWith(
      num4: item,
    );
  }

  AnimalEntity readNum2(Map<String, dynamic> json, value) {
    List<Menum>? items;
    if (value != null) {
      List<dynamic> map = value is List ? value : jsonDecode(value);
      items = map
          .map<Menum>((e) =>
              Menum.values.firstWhere((element) => element.name == e as String))
          .toList();
    }
    return copyWith(
      num2: CopyWith(items),
    );
  }

  AnimalEntity readNum6(Map<String, dynamic> json, value) {
    List<Menum>? items;
    if (value != null) {
      List<dynamic> map = value is List ? value : jsonDecode(value);
      items = map
          .map<Menum>((e) =>
              Menum.values.firstWhere((element) => element.name == e as String))
          .toList();
    }
    return copyWith(
      num6: items,
    );
  }

  AnimalEntity readTesting(Map<String, dynamic> json, value) {
    Testing? item;
    if (value != null) {
      Map<String, dynamic> map =
          value is Map<String, dynamic> ? value : jsonDecode(value);
      item = Testing.fromMap(map);
    }
    return copyWith(
      testing: CopyWith(item),
    );
  }

  AnimalEntity readTesting2(Map<String, dynamic> json, value) {
    List<Testing>? items;
    if (value != null) {
      List<dynamic> map = value is List ? value : jsonDecode(value);
      items = map.map<Testing>((e) => Testing.fromMap(e)).toList();
    }
    return copyWith(
      testing2: CopyWith(items),
    );
  }

  String? get text;
  List<String>? get list;
  List<DateTime>? get dt;
  DateTime? get dt1;
  Menum? get numnum;
  Menum get num4;
  List<Menum>? get num2;
  List<Menum> get num6;
  Testing? get testing;
  List<Testing>? get testing2;
  List<TextSpan>? get textSpans;

  @override
  List<Object?> get props => [
        ...super.props,
        text,
        list,
        dt,
        dt1,
        numnum,
        num4,
        num2,
        num6,
        testing,
        testing2,
        textSpans,
      ];
  @override
  AnimalEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    CopyWith<String?>? text,
    CopyWith<List<String>?>? list,
    CopyWith<List<DateTime>?>? dt,
    CopyWith<DateTime?>? dt1,
    CopyWith<Menum?>? numnum,
    Menum? num4,
    CopyWith<List<Menum>?>? num2,
    List<Menum>? num6,
    CopyWith<Testing?>? testing,
    CopyWith<List<Testing>?>? testing2,
    CopyWith<List<TextSpan>?>? textSpans,
    Map<String, dynamic>? json,
  }) {
    return AnimalEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      text: text != null ? text.value : this.text,
      list: list != null ? list.value : this.list,
      dt: dt != null ? dt.value : this.dt,
      dt1: dt1 != null ? dt1.value : this.dt1,
      numnum: numnum != null ? numnum.value : this.numnum,
      num4: num4 ?? this.num4,
      num2: num2 != null ? num2.value : this.num2,
      num6: num6 ?? this.num6,
      testing: testing != null ? testing.value : this.testing,
      testing2: testing2 != null ? testing2.value : this.testing2,
      textSpans: textSpans != null ? textSpans.value : this.textSpans,
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

  ColumnDefinition<AnimalEntity, String> get list =>
      ColumnDefinition<AnimalEntity, String>(
        'list',
        write: (entity) {
          final map = entity.list?.map((p) => p).toList();

          return jsonEncode(map);
        },
        read: (json, entity, value) {
          return entity.readList(json, value);
        },
      );

  ColumnDefinition<AnimalEntity, String> get dt =>
      ColumnDefinition<AnimalEntity, String>(
        'dt',
        write: (entity) {
          final map = entity.dt?.map((p) => p.toIso8601String()).toList();

          return jsonEncode(map);
        },
        read: (json, entity, value) {
          return entity.readDt(json, value);
        },
      );

  ColumnDefinition<AnimalEntity, DateTime> get dt1 =>
      ColumnDefinition<AnimalEntity, DateTime>(
        'dt1',
        write: (entity) => entity.dt1,
        read: (json, entity, value) =>
            entity.copyWith(dt1: CopyWith(value), json: json),
      );

  ColumnDefinition<AnimalEntity, String> get numnum =>
      ColumnDefinition<AnimalEntity, String>(
        'numnum',
        write: (entity) {
          if (entity.numnum == null) {
            return null;
          }
          final map = entity.numnum?.name;

          return map;
        },
        read: (json, entity, value) {
          return entity.readNumnum(json, value);
        },
      );

  ColumnDefinition<AnimalEntity, String> get num4 =>
      ColumnDefinition<AnimalEntity, String>(
        'num4',
        notNull: true,
        write: (entity) {
          final map = entity.num4.name;

          return map;
        },
        read: (json, entity, value) {
          return entity.readNum4(json, value);
        },
      );

  ColumnDefinition<AnimalEntity, String> get num2 =>
      ColumnDefinition<AnimalEntity, String>(
        'num2',
        write: (entity) {
          final map = entity.num2?.map((p) => p.name).toList();

          return jsonEncode(map);
        },
        read: (json, entity, value) {
          return entity.readNum2(json, value);
        },
      );

  ColumnDefinition<AnimalEntity, String> get num6 =>
      ColumnDefinition<AnimalEntity, String>(
        'num6',
        notNull: true,
        write: (entity) {
          final map = entity.num6.map((p) => p.name).toList();

          return jsonEncode(map);
        },
        read: (json, entity, value) {
          return entity.readNum6(json, value);
        },
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
          return entity.readTesting2(json, value);
        },
      );

  @override
  Iterable<ColumnDefinition<AnimalEntity, dynamic>> get columns => [
        id,
        createdAt,
        updatedAt,
        text,
        list,
        dt,
        dt1,
        numnum,
        num4,
        num2,
        num6,
        testing,
        testing2,
      ];
}

import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'entity.dart';
import 'sql_column_extension.dart';

class SqlColumn<TEntity extends IEntity, TType> extends Equatable {
  final String name;
  final String? alias;
  final bool jsonEncodeAlias;
  final bool primaryKey;
  final bool autoIncrementPrimary;
  final bool notNull;
  final bool unique;
  final ColumnType _columnType;

  ColumnType get columnType => _columnType;
  final TType? defaultValue;
  final dynamic Function(TEntity entity) saveToDb;
  final TEntity Function(TEntity entity, dynamic value) readFromDb;

  @override
  List<Object?> get props => [
        name,
        alias,
        jsonEncodeAlias,
        primaryKey,
        autoIncrementPrimary,
        notNull,
        unique,
        _columnType,
        defaultValue
      ];

  String toString() =>
      'StorageColumn<$TEntity, $TType> {name:$name, primaryKey:$primaryKey, autoIncrementPrimary:$autoIncrementPrimary, notNull:$notNull, unique:$unique, _columnType:$_columnType}';

  SqlColumn(
    this.name, {
    this.alias,
    this.jsonEncodeAlias = false,
    this.primaryKey = false,
    this.unique = false,
    this.autoIncrementPrimary = false,
    this.notNull = false,
    this.defaultValue,
    required dynamic Function(TEntity entity) saveToDb,
    required TEntity Function(TEntity entity, dynamic value) readFromDb,
  })  : _columnType = computeColumnType<TType>(),
        saveToDb = saveToDb,
        readFromDb = readFromDb;

  static ColumnType computeColumnType<TType>() {
    if (TType == String) {
      return ColumnType.Text;
    } else if (TType == DateTime) {
      return ColumnType.DateTime;
    } else if (TType == int) {
      return ColumnType.Integer;
    } else if (TType == bool) {
      return ColumnType.Boolean;
    } else if (TType == double) {
      return ColumnType.Real;
    } else {
      throw Exception('Column type not supported $TType');
    }
  }

  dynamic getValueFrom(Map<String, dynamic> map) {
    var value = map[name];
    if (value == null && alias != null && map[alias] != null) {
      value = jsonEncodeAlias ? jsonEncode(map[alias]) : map[alias];
    }
    if (TType == bool) return (value == true || value == 1) as TType;
    if (TType == DateTime) {
      var dt = value;
      if (dt != null) return DateTime.tryParse(dt) as TType;
      return null;
    }
    return value;
  }

  void commitValue(TEntity entity, Map<String, dynamic> map) {
    setValue(map, saveToDb(entity));
  }
}

enum ColumnType {
  Text,
  Integer,
  Real,
  Blob,
  Boolean,
  DateTime,
}

import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flora_orm/src/models/column_definition_extension.dart';
import 'package:flora_orm/src/models/entity.dart';

class ColumnDefinition<TEntity extends IEntity, TType> extends Equatable {
  ColumnDefinition(
    this.name, {
    required this.write,
    required this.read,
    this.alias,
    this.jsonEncodeAlias = false,
    this.primaryKey = false,
    this.unique = false,
    this.autoIncrementPrimary = false,
    this.notNull = false,
    this.defaultValue,
  }) : _columnType = computeColumnType<TType>();
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
  final TType? Function(TEntity entity) write;
  final TEntity Function(
    Map<String, dynamic> json,
    TEntity entity,
    dynamic value,
  ) read;

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
        defaultValue,
      ];

  @override
  String toString() =>
      'StorageColumn<$TEntity, $TType> {name:$name, primaryKey:$primaryKey, '
      'autoIncrementPrimary:$autoIncrementPrimary, notNull:$notNull, '
      'unique:$unique, _columnType:$_columnType}';

  static ColumnType computeColumnType<TType>() {
    if (TType == String) {
      return ColumnType.text;
    } else if (TType == DateTime) {
      return ColumnType.dateTime;
    } else if (TType == int) {
      return ColumnType.integer;
    } else if (TType == bool) {
      return ColumnType.boolean;
    } else if (TType == double) {
      return ColumnType.real;
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
      final dt = value as String?;
      if (dt != null) return DateTime.tryParse(dt) as TType;
      return null;
    }
    return value;
  }

  void commitValue(TEntity entity, Map<String, dynamic> map) {
    setValue(map, write(entity));
  }
}

enum ColumnType {
  text,
  integer,
  real,
  blob,
  boolean,
  dateTime,
}

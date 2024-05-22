import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'sql.dart';
import 'sql_column_extension.dart';

abstract class IEntity {
  const IEntity({
    this.id,
    this.createdAt,
    this.updatedAt,
  });
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  IEntity updateDates({DateTime? createdAt});

  IEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? json,
  });

  String get tableName;

  EntityMeta get meta;

  List<String> upgradeTable(int oldVersion, int newVersion);

  List<String> downgradeTable(int oldVersion, int newVersion);

  List<String> onUpgradeComplete(int oldVersion, int newVersion);

  List<String> onCreateComplete(int newVersion);

  List<String> onDowngradeComplete(int oldVersion, int newVersion);

  String createTable(int version);

  Map<String, dynamic> toMap();

  Map<String, dynamic> toDb();

  Map<String, dynamic> toStorageJson(
      {required Map<SqlColumn, dynamic> columnValues});

  IEntity load(Map<String, dynamic> json);
}

abstract class EntityMeta<TEntity extends IEntity> {
  const EntityMeta();
  Iterable<SqlColumn<TEntity, dynamic>> get columns;
  SqlColumn<IEntity, String> get id;

  SqlColumn<IEntity, DateTime> get createdAt;

  SqlColumn<IEntity, DateTime> get updatedAt;
}

abstract class Entity<TEntity extends IEntity,
    TMeta extends EntityMeta<TEntity>> extends Equatable implements IEntity {
  const Entity({
    this.id,
    this.createdAt,
    this.updatedAt,
  });
  @override
  final String? id;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  TMeta get meta;

  @override
  List<Object?> get props => [
        id,
      ];

  @override
  String toString() => indentedString({runtimeType.toString(): toMap()});

  String indentedString(json) {
    var encoder = const JsonEncoder.withIndent('     ');
    return encoder.convert(json);
  }

  @override
  TEntity copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? json,
  });

  List<SqlColumn<TEntity, dynamic>> get compositePrimaryKey =>
      <SqlColumn<TEntity, dynamic>>[];

  @override
  TEntity updateDates({DateTime? createdAt}) {
    createdAt ??= this.createdAt ?? DateTime.now().toUtc();
    var updatedAt = DateTime.now().toUtc();
    return copyWith(
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    for (var column in meta.columns) {
      column.commitValue(this as TEntity, map);
    }
    return map;
  }

  @override
  Map<String, dynamic> toDb() {
    Map<String, dynamic> map = {};
    for (var column in meta.columns) {
      column.commitValue(this as TEntity, map);
    }
    return map;
  }

  ///Reads the values from database and set the corresponding values
  @override
  TEntity load(Map<String, dynamic> json) {
    TEntity entity = this as TEntity;
    for (var column in meta.columns) {
      final value = column.getValueFrom(json);
      if (column is SqlColumn<TEntity, double> && value is int) {
        entity = column.read(json, entity, value.toDouble());
      } else {
        entity = column.read(json, entity, value);
      }
    }
    return entity;
  }

  List<String> recreateTable(int newVersion) {
    return [
      dropTable(tableName),
      createTable(newVersion),
    ];
  }

  @override
  String createTable(int version) {
    int indx = 1;
    StringBuffer stringBuffer = StringBuffer();
    for (var element in meta.columns) {
      stringBuffer
          .write('${element.name} ${getColumnType(element.columnType)}');
      columnDefinition(element, stringBuffer);
      if (indx++ != meta.columns.length) stringBuffer.write(',');
    }

    var composite = '';
    if (compositePrimaryKey.isNotEmpty) {
      bool firstItem = true;
      var keys = compositePrimaryKey.fold('', (prev, element) {
        var cm = ', ';
        if (firstItem) {
          cm = '';
          firstItem = false;
        }
        return '$prev$cm${element.name}';
      });
      composite = ',\n PRIMARY KEY ($keys)';
    }
    return '''
  CREATE TABLE IF NOT EXISTS $tableName (
  ${stringBuffer.toString()}$composite)
  ''';
  }

  String dropTable(String tableName) {
    return 'DROP TABLE IF EXISTS $tableName';
  }

  @override
  Map<String, dynamic> toStorageJson(
      {required Map<SqlColumn, dynamic> columnValues}) {
    Map<String, dynamic> map = {};
    columnValues.forEach((key, value) {
      key.setValue(map, value);
    });
    return map;
  }

  @protected
  String addColumn(SqlColumn column) {
    var str = StringBuffer();
    columnDefinition(column, str);
    return 'ALTER TABLE $tableName ADD ${column.name} ${getColumnType(column.columnType)}${str.toString()}';
  }

  @protected
  String getColumnType(ColumnType columnType) {
    switch (columnType) {
      case ColumnType.text:
      case ColumnType.dateTime:
        return 'TEXT';
      case ColumnType.boolean:
      case ColumnType.integer:
        return 'INTEGER';
      case ColumnType.real:
        return 'REAL';
      case ColumnType.blob:
        return 'BLOB';
      default:
        return 'TEXT';
    }
  }

  @protected
  void columnDefinition(SqlColumn element, StringBuffer stringBuffer) {
    if (element.primaryKey) stringBuffer.write(' PRIMARY KEY');
    if (element.autoIncrementPrimary) stringBuffer.write(' AUTOINCREMENT');
    if (element.unique) stringBuffer.write(' UNIQUE');
    if (element.notNull) stringBuffer.write(' NOT NULL');
    if (element.defaultValue != null) {
      stringBuffer.write(
          ' DEFAULT ${generateDefaultValue(colType: element.columnType, defaultValue: element.defaultValue)}');
    }
  }

  dynamic generateDefaultValue(
      {required ColumnType colType, required dynamic defaultValue}) {
    switch (colType) {
      case ColumnType.text:
        return "'$defaultValue'";
      case ColumnType.boolean:
        if (defaultValue is bool) {
          return defaultValue ? 1 : 0;
        }
        break;
      default:
        break;
    }
    return defaultValue;
  }

  @override
  List<String> upgradeTable(int oldVersion, int newVersion) {
    return [];
  }

  @override
  List<String> downgradeTable(int oldVersion, int newVersion) {
    return [];
  }

  @override
  List<String> onUpgradeComplete(int oldVersion, int newVersion) {
    return [];
  }

  @override
  List<String> onCreateComplete(int newVersion) {
    return [];
  }

  @override
  List<String> onDowngradeComplete(int oldVersion, int newVersion) {
    return [];
  }
}

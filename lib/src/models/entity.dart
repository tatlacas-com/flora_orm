import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'sql.dart';
import 'sql_column_extension.dart';

abstract class IEntity {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const IEntity({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  IEntity updateDates();

  IEntity setBaseParams({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  String get tableName;

  SqlColumn<IEntity, String> get columnId;

  SqlColumn<IEntity, DateTime> get columnCreatedAt;

  SqlColumn<IEntity, DateTime> get columnUpdatedAt;

  Iterable<SqlColumn> get columns;

  Iterable<SqlColumn> get allColumns;

  List<String> upgradeTable(int oldVersion, int newVersion);

  List<String> downgradeTable(int oldVersion, int newVersion);

  List<String> onUpgradeComplete(int oldVersion, int newVersion);

  List<String> onCreateComplete(int newVersion);

  List<String> onDowngradeComplete(int oldVersion, int newVersion);

  String createTable(int version);

  Map<String, dynamic> toJson();

  Map<String, dynamic> toDb();

  Map<String, dynamic> toStorageJson(
      {required Map<SqlColumn, dynamic> columnValues});

  IEntity load(Map<String, dynamic> json);
}

abstract class Entity<TEntity extends IEntity> extends Equatable
    implements IEntity {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Entity({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
      ];

  @override
  String toString() => indentedString({runtimeType.toString(): toJson()});

  String indentedString(json) {
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(json);
  }

  Iterable<SqlColumn<TEntity, dynamic>> get columns;

  Iterable<SqlColumn<TEntity, dynamic>> get allColumns =>
      <SqlColumn<TEntity, dynamic>>[columnId, columnCreatedAt, columnUpdatedAt]
          .followedBy(columns);

  @override
  TEntity setBaseParams({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  SqlColumn<TEntity, String> get columnId => SqlColumn<TEntity, String>(
        'id',
        primaryKey: true,
        read: (entity) => entity.id,
        write: (entity, value) => entity.setBaseParams(id: value) as TEntity,
      );

  SqlColumn<TEntity, DateTime> get columnCreatedAt =>
      SqlColumn<TEntity, DateTime>(
        'createdAt',
        read: (entity) => entity.createdAt,
        write: (entity, value) =>
            entity.setBaseParams(createdAt: value) as TEntity,
      );

  SqlColumn<TEntity, DateTime> get columnUpdatedAt =>
      SqlColumn<TEntity, DateTime>(
        'updatedAt',
        read: (entity) => entity.updatedAt,
        write: (entity, value) =>
            entity.setBaseParams(updatedAt: value) as TEntity,
      );

  List<SqlColumn<TEntity, dynamic>> get compositePrimaryKey =>
      <SqlColumn<TEntity, dynamic>>[];

  TEntity updateDates() {
    var createdAt = this.createdAt ?? DateTime.now().toUtc();
    var updatedAt = DateTime.now().toUtc();
    return setBaseParams(
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    allColumns.forEach((column) {
      column.commitValue(this as TEntity, map);
    });
    return map;
  }

  ///Reads the values from database and set the corresponding values
  TEntity load(Map<String, dynamic> json) {
    TEntity entity = this as TEntity;
    allColumns.forEach((column) {
      try {
        final value = column.getValueFrom(json);
        entity = column.write(entity, value);
      } catch (e) {
        throw ArgumentError('Error loading ${column.name}: $e');
      }
    });
    return entity;
  }

  String createTable(int version) {
    int indx = 1;
    StringBuffer stringBuffer = StringBuffer();
    allColumns.forEach((element) {
      stringBuffer
          .write('${element.name} ${getColumnType(element.columnType)}');
      columnDefinition(element, stringBuffer);
      if (indx++ != allColumns.length) stringBuffer.write(',');
    });

    var composite = '';
    if (compositePrimaryKey.length > 0) {
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
  String dropColumn(String name) {
    return 'ALTER TABLE $tableName DROP $name';
  }

  @protected
  String getColumnType(ColumnType columnType) {
    switch (columnType) {
      case ColumnType.Text:
      case ColumnType.DateTime:
        return 'TEXT';
      case ColumnType.Boolean:
      case ColumnType.Integer:
        return 'INTEGER';
      case ColumnType.Real:
        return 'REAL';
      case ColumnType.Blob:
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
    if (element.defaultValue != null)
      stringBuffer.write(
          ' DEFAULT ${generateDefaultValue(colType: element.columnType, defaultValue: element.defaultValue)}');
  }

  dynamic generateDefaultValue(
      {required ColumnType colType, required dynamic defaultValue}) {
    switch (colType) {
      case ColumnType.Text:
        return "'$defaultValue'";
      case ColumnType.Boolean:
        if (defaultValue is bool) {
          return defaultValue ? 1 : 0;
        }
        break;
      default:
        break;
    }
    return defaultValue;
  }

  List<String> upgradeTable(int oldVersion, int newVersion) {
    return [];
  }

  List<String> downgradeTable(int oldVersion, int newVersion) {
    return [];
  }

  List<String> onUpgradeComplete(int oldVersion, int newVersion) {
    return [];
  }

  List<String> onCreateComplete(int newVersion) {
    return [];
  }

  List<String> onDowngradeComplete(int oldVersion, int newVersion) {
    return [];
  }
}

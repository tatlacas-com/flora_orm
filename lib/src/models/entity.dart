import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flora_orm/src/models/column_definition_extension.dart';
import 'package:flora_orm/src/models/orm.dart';
import 'package:meta/meta.dart';
part 'entity_base.dart';
part 'entity_meta.dart';

abstract class Entity<TEntity extends EntityBase,
    TMeta extends EntityMeta<TEntity>> extends Equatable implements EntityBase {
  const Entity({
    this.id,
    this.collectionId,
    this.createdAt,
    this.updatedAt,
  });
  @override
  final String? id;
  @override
  final String? collectionId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  TMeta get meta;

  @override
  List<Object?> get props => [
        id,
        collectionId,
      ];

  @override
  String toString() => indentedString({runtimeType.toString(): toMap()});

  String indentedString(dynamic json) {
    const encoder = JsonEncoder.withIndent('     ');
    return encoder.convert(json);
  }

  @override
  TEntity copyWith({
    String? id,
    String? collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? json,
  });

  List<ColumnDefinition<TEntity, dynamic>> get compositePrimaryKey =>
      <ColumnDefinition<TEntity, dynamic>>[];

  @override
  TEntity updateDates({DateTime? createdAt}) {
    createdAt ??= this.createdAt ?? DateTime.now().toUtc();
    final updatedAt = DateTime.now().toUtc();
    return copyWith(
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    for (final column in meta.columns) {
      column.commitValue(this as TEntity, map);
    }
    return map;
  }

  @override
  Map<String, dynamic> toDb() {
    final map = <String, dynamic>{};
    for (final column in meta.columns) {
      column.commitValue(this as TEntity, map);
    }
    return map;
  }

  ///Reads the values from database and set the corresponding values
  @override
  TEntity load(Map<String, dynamic> json) {
    var entity = this as TEntity;
    for (final column in meta.columns) {
      final value = column.getValueFrom(json);
      if (column is ColumnDefinition<TEntity, double> && value is int) {
        entity = column.read(json, entity, value.toDouble());
      } else {
        entity = column.read(json, entity, value);
      }
    }
    return entity;
  }

  @override
  @nonVirtual
  List<String> recreateTable(int newVersion) {
    return [
      dropTable(meta.tableName),
      createTable(newVersion),
    ];
  }

  List<ColumnDefinition<TEntity, dynamic>> addColumnsAt(int newVersion);

  @override
  @nonVirtual
  String createTable(int version) {
    var indx = 1;
    final stringBuffer = StringBuffer();
    for (final element in meta.columns) {
      stringBuffer
          .write('${element.name} ${getColumnType(element.columnType)}');
      columnDefinition(element, stringBuffer);
      if (indx++ != meta.columns.length) stringBuffer.write(',');
    }

    var composite = '';
    if (compositePrimaryKey.isNotEmpty) {
      var firstItem = true;
      final keys = compositePrimaryKey.fold('', (prev, element) {
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
  CREATE TABLE IF NOT EXISTS ${meta.tableName} (
  $stringBuffer$composite)
  ''';
  }

  @protected
  @nonVirtual
  String dropTable(String tableName) {
    return 'DROP TABLE IF EXISTS $tableName';
  }

  Map<String, dynamic> toStorageJson({
    required Map<ColumnDefinition<TEntity, dynamic>, dynamic> columnValues,
  }) {
    final map = <String, dynamic>{};
    columnValues.forEach((key, value) {
      key.setValue(map, value);
    });
    return map;
  }

  String addColumn(ColumnDefinition<TEntity, dynamic> column) {
    final str = StringBuffer();
    columnDefinition(column, str);
    return 'ALTER TABLE ${meta.tableName} ADD ${column.name} '
        '${getColumnType(column.columnType)}$str';
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
    }
  }

  @protected
  void columnDefinition(
    ColumnDefinition<TEntity, dynamic> element,
    StringBuffer stringBuffer,
  ) {
    if (element.primaryKey) stringBuffer.write(' PRIMARY KEY');
    if (element.autoIncrementPrimary) stringBuffer.write(' AUTOINCREMENT');
    if (element.unique) stringBuffer.write(' UNIQUE');
    if (element.notNull) stringBuffer.write(' NOT NULL');
    if (element.defaultValue != null) {
      stringBuffer.write(
        ' DEFAULT ${generateDefaultValue(
          colType: element.columnType,
          defaultValue: element.defaultValue,
        )}',
      );
    }
  }

  dynamic generateDefaultValue({
    required ColumnType colType,
    required dynamic defaultValue,
  }) {
    return switch (colType) {
      ColumnType.text => "'$defaultValue'",
      ColumnType.boolean =>
        (defaultValue is bool) ? (defaultValue ? 1 : 0) : defaultValue,
      ColumnType.integer => defaultValue,
      ColumnType.real => defaultValue,
      ColumnType.blob => defaultValue,
      ColumnType.dateTime => defaultValue,
    };
  }

  @override
  List<String> additionalUpgradeQueries(int oldVersion, int newVersion) {
    return [];
  }

  @override
  bool recreateTableAt(int newVersion) => false;

  @override
  bool createTableAt(int newVersion) => false;

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

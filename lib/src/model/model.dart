import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flora_orm/src/model/column_definition_extension.dart';
import 'package:flora_orm/src/model/orm.dart';
import 'package:meta/meta.dart';
part 'model_base.dart';
part 'model_meta.dart';

abstract class Model<TModel extends ModelBase, TMeta extends ModelMeta<TModel>>
    extends Equatable
    implements ModelBase {
  const Model({this.id, this.restorationId, this.createdAt, this.updatedAt});
  @override
  final String? id;
  @override
  final String? restorationId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  TMeta get meta;

  @override
  List<Object?> get props => [id, restorationId];

  @override
  String toString() => indentedString({runtimeType.toString(): toMap()});

  String indentedString(dynamic json) {
    const encoder = JsonEncoder.withIndent('     ');
    return encoder.convert(json);
  }

  @override
  TModel copyWith({
    String? id,
    String? restorationId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? json,
  });

  List<ColumnDefinition<TModel, dynamic>> get compositePrimaryKey =>
      <ColumnDefinition<TModel, dynamic>>[];

  @override
  TModel updateDates({DateTime? createdAt}) {
    createdAt ??= this.createdAt ?? DateTime.now().toUtc();
    final updatedAt = DateTime.now().toUtc();
    return copyWith(createdAt: createdAt, updatedAt: updatedAt);
  }

  @override
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    for (final column in meta.columns) {
      column.commitValue(this as TModel, map);
    }
    return map;
  }

  @override
  Map<String, dynamic> toDb() {
    final map = <String, dynamic>{};
    for (final column in meta.columns) {
      column.commitValue(this as TModel, map);
    }
    return map;
  }

  ///Reads the values from database and set the corresponding values
  @override
  TModel load(Map<String, dynamic> json) {
    var model = this as TModel;
    for (final column in meta.columns) {
      final value = column.getValueFrom(json);
      if (column is ColumnDefinition<TModel, double> && value is int) {
        model = column.read(json, model, value.toDouble());
      } else {
        model = column.read(json, model, value);
      }
    }
    return model;
  }

  @override
  @nonVirtual
  List<String> recreateTable(int newVersion) {
    return [dropTable(meta.tableName), createTable(newVersion)];
  }

  List<ColumnDefinition<TModel, dynamic>> addColumnsAt(int newVersion);

  @override
  @nonVirtual
  String createTable(int version) {
    var indx = 1;
    final stringBuffer = StringBuffer();
    for (final element in meta.columns) {
      stringBuffer.write(
        '${element.name} ${getColumnType(element.columnType)}',
      );
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
    required Map<ColumnDefinition<TModel, dynamic>, dynamic> columnValues,
  }) {
    final map = <String, dynamic>{};
    columnValues.forEach((key, value) {
      key.setValue(map, value);
    });
    return map;
  }

  String addColumn(ColumnDefinition<TModel, dynamic> column) {
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
    ColumnDefinition<TModel, dynamic> element,
    StringBuffer stringBuffer,
  ) {
    if (element.primaryKey) stringBuffer.write(' PRIMARY KEY');
    if (element.autoIncrementPrimary) stringBuffer.write(' AUTOINCREMENT');
    if (element.unique) stringBuffer.write(' UNIQUE');
    if (element.notNull) stringBuffer.write(' NOT NULL');
    if (element.defaultValue != null) {
      stringBuffer.write(
        ''' DEFAULT ${generateDefaultValue(colType: element.columnType, defaultValue: element.defaultValue)}''',
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

import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:tatlacas_sqflite_storage/src/base_context.dart';
import 'package:uuid/uuid.dart';

import '../sql.dart';
import 'models/sql_order.dart';

class BaseStorage<TEntity extends IEntity, TDbContext extends BaseContext>
    extends SqlStorage<TEntity, TDbContext> {
  /// Try to convert anything (int, String) to an int.
  int? parseInt(Object? object) {
    if (object is int) {
      return object;
    } else if (object is String) {
      try {
        return int.parse(object);
      } catch (_) {}
    }
    return null;
  }

  const BaseStorage({required TDbContext dbContext})
      : super(dbContext: dbContext);

  Future<TEntity?> insert(TEntity item) async {
    if (item.id == null) item = item.setBaseParams(id: Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final db = await dbContext.database;
    final updated = await db.insert(item.tableName, item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.abort);
    return updated > 0 ? item : null;
  }

  Future<List<TEntity>?> insertList(Iterable<TEntity> items) async {
    final db = await dbContext.database;
    List<TEntity>? result;
    List<TEntity> updatedItems = <TEntity>[];
    await db.transaction((txn) async {
      var batch = txn.batch();
      items.forEach((element) {
        if (element.id == null)
          element = element.setBaseParams(id: Uuid().v4()) as TEntity;
        element = element.updateDates() as TEntity;
        batch.insert(element.tableName, element.toJson(),
            conflictAlgorithm: ConflictAlgorithm.abort);
        updatedItems.add(element);
      });
      result = await _finishBatch(batch, updatedItems);
    });
    return result;
  }

  Future<TEntity?> insertOrUpdate(TEntity item) async {
    final db = await dbContext.database;
    if (item.id == null) item = item.setBaseParams(id: Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final updated = await db.insert(item.tableName, item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return updated > 0 ? item : null;
  }

  Future<Map<String, dynamic>?> getEntity(
    TEntity type, {
    Iterable<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
    required SqlWhere where,
  }) async {
    List<Map<String, dynamic>> maps = await query(
        where: where,
        type: type,
        columns: columns ?? type.allColumns,
        orderBy: orderBy);
    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }

  Future<T> getSum<T>(
    TEntity type, {
    required SqlColumn column,
    SqlWhere? where,
  }) async {
    List<Map> result = await rawQuery(
        where, 'SELECT SUM (${column.name}) FROM ${type.tableName}');
    if (result.isNotEmpty) {
      final firstRow = result.first;
      if (firstRow.isNotEmpty) {
        return firstRow.values.first as T;
      }
    }
    return 0 as T;
  }

  Future<T> getSumProduct<T>(
    TEntity type, {
    required Iterable<SqlColumn> columns,
    SqlWhere? where,
  }) async {
    final cols = columns.map((e) => e.name).join(' * ');
    List<Map> result =
        await rawQuery(where, 'SELECT SUM ($cols) FROM ${type.tableName}');
    if (result.isNotEmpty) {
      final firstRow = result.first;
      if (firstRow.isNotEmpty) {
        return firstRow.values.first as T;
      }
    }
    return 0 as T;
  }

  Future<List<Map<String, dynamic>>> getEntities(
    TEntity type, {
    Iterable<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
    SqlWhere? where,
  }) async {
    List<Map<String, Object?>> maps = await query(
        where: where,
        type: type,
        columns: columns ?? type.allColumns,
        orderBy: orderBy);
    if (maps.isNotEmpty) {
      return maps;
    }
    return [];
  }

  Future<List<TEntity>?> insertOrUpdateList(Iterable<TEntity> items) async {
    final db = await dbContext.database;
    List<TEntity>? result;
    List<TEntity> updatedItems = <TEntity>[];
    await db.transaction((txn) async {
      var batch = txn.batch();
      items.forEach((element) {
        if (element.id == null)
          element = element.setBaseParams(id: Uuid().v4()) as TEntity;
        element = element.updateDates() as TEntity;
        updatedItems.add(element);
        batch.insert(element.tableName, element.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
      result = await _finishBatch(batch, updatedItems);
    });
    return result;
  }

  Future<List<TEntity>> _finishBatch(
      Batch batch, Iterable<TEntity> items) async {
    var result = await batch.commit(noResult: false, continueOnError: true);
    List<TEntity> inserted = <TEntity>[];
    var indx = 0;
    result.forEach((element) {
      if (element is int && element > 0) {
        inserted.add(items.elementAt(indx));
      }
      indx++;
    });
    return inserted;
  }

  Future<int?> getCount(
    TEntity type, {
    SqlWhere? where,
  }) async {
    List<Map<String, Object?>> result =
        await rawQuery(where, 'SELECT COUNT (*) FROM ${type.tableName}');
    if (result.isNotEmpty) {
      final firstRow = result.first;
      if (firstRow.isNotEmpty) {
        return parseInt(firstRow.values.first);
      }
    }
    return 0;
  }

  Future<int> delete(
    TEntity type, {
    required SqlWhere where,
  }) async {
    final db = await dbContext.database;
    final formattedQuery = whereString(where);
    return await db.delete(
      type.tableName,
      where: formattedQuery.where,
      whereArgs: formattedQuery.whereArgs,
    );
  }

  Future<int> update(
    TEntity item, {
    required SqlWhere where,
    Map<SqlColumn, dynamic>? columnValues,
  }) async {
    final db = await dbContext.database;
    final formattedQuery = whereString(where);
    item = item.updateDates() as TEntity;
    final update = columnValues != null
        ? item.toStorageJson(columnValues: columnValues)
        : item.toJson();
    return await db.update(
      item.tableName,
      update,
      where: formattedQuery.where,
      whereArgs: formattedQuery.whereArgs,
    );
  }


  @protected
  Future<List<Map<String, dynamic>>> query({
    SqlWhere? where,
    required TEntity type,
    Iterable<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
  }) async {
    List<Map<String, dynamic>> maps;
    final db = await dbContext.database;
    if (columns == null || columns.isEmpty)
      throw ArgumentError('no columns supplied');
    List<String> cols = [];
    columns.forEach((element) {
      cols.add(element.name);
    });
    String? orderByFilter;
    if (orderBy?.isNotEmpty == true) {
      orderByFilter = orderBy!
          .map((e) =>
              '${e.column.name} ${e.direction == OrderDirection.Desc ? ' DESC' : ''}')
          .join(',');
    }
    if (where == null)
      maps = await db.query(
        type.tableName,
        columns: cols,
        orderBy: orderByFilter,
      );
    else {
      final formattedQuery = whereString(where);
      maps = await db.query(
        type.tableName,
        columns: cols,
        where: formattedQuery.where,
        whereArgs: formattedQuery.whereArgs,
        orderBy: orderByFilter,
      );
    }
    return maps;
  }

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    SqlWhere? where,
    String query,
  ) async {
    final db = await dbContext.database;
    if (where == null)
      return await db.rawQuery(query);
    else {
      final formattedQuery = whereString(where);
      return await db.rawQuery(
          '$query WHERE ${formattedQuery.where}', formattedQuery.whereArgs);
    }
  }

  @override
  List<Object?> get props => [dbContext];

}

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tatlacas_sql_storage/tatlacas_sql_storage.dart';

import 'sqflite_db_context.dart';

class SqfliteStorage<TEntity extends Entity>
    extends SqlStorage<TEntity, SqfliteDbContext> {
  const SqfliteStorage({required SqfliteDbContext dbContext})
      : super(dbContext: dbContext);

  Future<int> insert(TEntity item) async {
    final db = await dbContext.database;
    return await db.insert(item.tableName, item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future insertList(List<TEntity> items) async {
    final db = await dbContext.database;
    await db.transaction((txn) async {
      var batch = txn.batch();
      items.forEach((element) {
        batch.insert(element.tableName, element.toJson(),
            conflictAlgorithm: ConflictAlgorithm.abort);
      });
      await batch.commit(noResult: true);
    });
  }

  Future<int> insertOrUpdate(TEntity item) async {
    final db = await dbContext.database;
    return await db.insert(item.tableName, item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getEntity(
    TEntity type, {
    List<SqlColumn>? columns,
    List<SqlColumn>? orderBy,
    required SqlWhere where,
  }) async {
    List<Map<String, dynamic>> maps = await query(
        where: where,
        type: type,
        columns: columns ?? type.columns,
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
        return (firstRow.values.first as T?) ?? 0 as T;
      }
    }
    return 0 as T;
  }

  Future<T> getSumProduct<T>(
    TEntity type, {
    required List<SqlColumn> columns,
    SqlWhere? where,
  }) async {
    final cols = columns.map((e) => e.name).join(' * ');
    List<Map> result =
        await rawQuery(where, 'SELECT SUM ($cols) FROM ${type.tableName}');
    if (result.isNotEmpty) {
      final firstRow = result.first;
      if (firstRow.isNotEmpty) {
        return (firstRow.values.first as T?) ?? 0 as T;
      }
    }
    return 0 as T;
  }

  Future<List<Map<String, dynamic>>> getEntities(
    TEntity type, {
    List<SqlColumn>? columns,
    List<SqlColumn>? orderBy,
    SqlWhere? where,
  }) async {
    List<Map<String, Object?>> maps = await query(
        where: where,
        type: type,
        columns: columns ?? type.columns,
        orderBy: orderBy);
    if (maps.isNotEmpty) {
      return maps;
    }
    return [];
  }

  Future insertOrUpdateList(List<TEntity> items) async {
    final db = await dbContext.database;
    await db.transaction((txn) async {
      var batch = txn.batch();
      items.forEach((element) {
        batch.insert(element.tableName, element.toJson(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
      await batch.commit(noResult: true);
    });
  }

  Future<int> getCount(
    TEntity type, {
    SqlWhere? where,
  }) async {
    List<Map<String, Object?>> result =
        await rawQuery(where, 'SELECT COUNT (*) FROM ${type.tableName}');
    if (result.isNotEmpty) {
      return Sqflite.firstIntValue(result) ?? 0;
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
    List<SqlColumn>? columns,
    List<SqlColumn>? orderBy,
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
      orderByFilter = columns.map((e) => e.name).join(',');
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

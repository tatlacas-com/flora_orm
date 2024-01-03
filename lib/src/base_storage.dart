import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:tatlacas_sqflite_storage/src/base_context.dart';
import 'package:uuid/uuid.dart';

import '../sql.dart';

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

  const BaseStorage(TEntity t, {required TDbContext dbContext})
      : super(t, dbContext: dbContext);

  Future<TEntity?> insert(TEntity item) async {
    if (item.id == null) item = item.copyWith(id: Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final db = await dbContext.database;
    final updated = await db.insert(item.tableName, item.toDb(),
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
          element = element.copyWith(id: Uuid().v4()) as TEntity;
        element = element.updateDates() as TEntity;
        batch.insert(element.tableName, element.toMap(),
            conflictAlgorithm: ConflictAlgorithm.abort);
        updatedItems.add(element);
      });
      result = await _finishBatch(batch, updatedItems);
    });
    return result;
  }

  @override
  Future<TEntity?> insertOrUpdate(TEntity item) async {
    final db = await dbContext.database;
    if (item.id == null) item = item.copyWith(id: Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final updated = await db.insert(item.tableName, item.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return updated > 0 ? item : null;
  }

  @override
  Future<TEntity?> getEntity({
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required SqlWhere Function(TEntity t) where,
    int? offset,
  }) async {
    List<TEntity> maps = await query(
      where: where,
      columns: columns ?? (t) => t.allColumns,
      limit: 1,
      offset: offset,
      orderBy: orderBy,
    );
    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getEntityMap({
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required SqlWhere Function(TEntity t) where,
    int? offset,
  }) async {
    List<Map<String, dynamic>> maps = await queryMap(
      where: where,
      columns: columns ?? (t) => t.allColumns,
      limit: 1,
      offset: offset,
      orderBy: orderBy,
    );
    if (maps.length > 0) {
      return maps.first;
    }
    return null;
  }

  @override
  Future<T> getSum<T>({
    required SqlColumn Function(TEntity t) column,
    SqlWhere Function(TEntity t)? where,
  }) async {
    List<Map> result = await rawQuery(
        where, 'SELECT SUM (${column(t).name}) FROM ${t.tableName}');
    if (result.isNotEmpty) {
      final firstRow = result.first;
      if (firstRow.isNotEmpty && firstRow.values.first != null) {
        return asCast<T>(firstRow.values.first);
      }
    }
    return asCast<T>(0);
  }

  @override
  Future<T> getSumProduct<T>({
    required Iterable<SqlColumn> Function(TEntity t) columns,
    SqlWhere Function(TEntity t)? where,
  }) async {
    final cols = columns(t).map((e) => e.name).join(' * ');
    List<Map> result =
        await rawQuery(where, 'SELECT SUM ($cols) FROM ${t.tableName}');
    if (result.isNotEmpty) {
      final firstRow = result.first;
      if (firstRow.isNotEmpty && firstRow.values.first != null) {
        return asCast<T>(firstRow.values.first);
      }
    }
    return asCast<T>(0);
  }

  T asCast<T>(dynamic value) {
    if (T == int && value is double) {
      return value.toInt() as T;
    } else if (T == double && value is int) {
      return value.toDouble() as T;
    }
    return value as T;
  }

  @override
  Future<List<TEntity>> getEntities({
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    SqlWhere Function(TEntity t)? where,
    int? limit,
    int? offset,
  }) async {
    List<TEntity> maps = await query(
      where: where,
      limit: limit,
      offset: offset,
      columns: columns ?? (t) => t.allColumns,
      orderBy: orderBy,
    );
    if (maps.isNotEmpty) {
      return maps;
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getEntityMaps({
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    SqlWhere Function(TEntity t)? where,
    int? limit,
    int? offset,
  }) async {
    List<Map<String, Object?>> maps = await queryMap(
      where: where,
      limit: limit,
      offset: offset,
      columns: columns ?? (t) => t.allColumns,
      orderBy: orderBy,
    );
    if (maps.isNotEmpty) {
      return maps;
    }
    return [];
  }

  @override
  Future<List<TEntity>?> insertOrUpdateList(Iterable<TEntity> items) async {
    final db = await dbContext.database;
    List<TEntity>? result;
    List<TEntity> updatedItems = <TEntity>[];
    await db.transaction((txn) async {
      var batch = txn.batch();
      items.forEach((element) {
        if (element.id == null)
          element = element.copyWith(id: Uuid().v4()) as TEntity;
        element = element.updateDates() as TEntity;
        updatedItems.add(element);
        batch.insert(element.tableName, element.toMap(),
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

  @override
  Future<int> getCount({
    SqlWhere Function(TEntity t)? where,
  }) async {
    List<Map<String, Object?>> result =
        await rawQuery(where, 'SELECT COUNT (*) FROM ${t.tableName}');
    if (result.isNotEmpty) {
      final firstRow = result.first;
      if (firstRow.isNotEmpty) {
        return parseInt(firstRow.values.first) ?? 0;
      }
    }
    return 0;
  }

  @override
  Future<int> delete({
    final SqlWhere Function(TEntity t)? where,
  }) async {
    final db = await dbContext.database;
    final formattedQuery = where != null ? whereString(where) : null;
    return await db.delete(
      t.tableName,
      where: formattedQuery?.where,
      whereArgs: formattedQuery?.whereArgs,
    );
  }

  @override
  Future<int> update({
    required SqlWhere Function(TEntity t) where,
    TEntity? entity,
    Map<SqlColumn, dynamic> Function(TEntity t)? columnValues,
  }) async {
    assert(entity != null || columnValues != null);
    final db = await dbContext.database;
    final formattedQuery = whereString(where);
    var createdAt = entity?.createdAt;
    if (entity == null) {
      final res =
          await getEntityMap(where: where, columns: (t) => [t.columnCreatedAt]);
      if (res?.containsKey(t.columnCreatedAt.name) == true) {
        createdAt = DateTime.parse(res![t.columnCreatedAt.name]);
      }
    }
    entity = (entity ?? t).updateDates(createdAt: createdAt) as TEntity;
    final update = columnValues != null
        ? entity.toStorageJson(columnValues: columnValues(t))
        : entity.toDb();
    return await db.update(
      entity.tableName,
      update,
      where: formattedQuery.where,
      whereArgs: formattedQuery.whereArgs,
    );
  }

  @override
  @protected
  Future<List<TEntity>> query({
    SqlWhere Function(TEntity t)? where,
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<Map<String, dynamic>> maps;
    final db = await dbContext.database;
    final cols1 = columns?.call(t);
    if (cols1 == null) {
      throw ArgumentError('no columns supplied');
    }
    List<String> cols = [];
    cols1.forEach((element) {
      cols.add(element.name);
    });
    if (cols.isEmpty) {
      throw ArgumentError('no columns supplied');
    }
    String? orderByFilter = orderBy
        ?.call(t)
        ?.map((e) =>
            '${e.column.name} ${e.direction == OrderDirection.Desc ? ' DESC' : ''}')
        .join(',');

    if (where == null)
      maps = await db.query(
        t.tableName,
        columns: cols,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    else {
      final formattedQuery = whereString(where);
      maps = await db.query(
        t.tableName,
        columns: cols,
        where: formattedQuery.where,
        whereArgs: formattedQuery.whereArgs,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    }
    List<TEntity> entities = [];
    for (final item in maps) {
      entities.add(t.load(item) as TEntity);
    }
    return entities;
  }

  @override
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    SqlWhere Function(TEntity t)? where,
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<Map<String, dynamic>> maps;
    final db = await dbContext.database;
    final cols1 = columns?.call(t);
    if (cols1 == null) {
      throw ArgumentError('no columns supplied');
    }
    List<String> cols = [];
    cols1.forEach((element) {
      cols.add(element.name);
    });
    if (cols.isEmpty) {
      throw ArgumentError('no columns supplied');
    }
    String? orderByFilter = orderBy
        ?.call(t)
        ?.map((e) =>
            '${e.column.name} ${e.direction == OrderDirection.Desc ? ' DESC' : ''}')
        .join(',');

    if (where == null)
      maps = await db.query(
        t.tableName,
        columns: cols,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    else {
      final formattedQuery = whereString(where);
      maps = await db.query(
        t.tableName,
        columns: cols,
        where: formattedQuery.where,
        whereArgs: formattedQuery.whereArgs,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    }
    return maps;
  }

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    SqlWhere Function(TEntity t)? where,
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

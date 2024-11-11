import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:flora_orm/src/contexts/base_context.dart';
import 'package:flora_orm/src/engines/orm_engine.dart';
import 'package:flora_orm/src/models/entity.dart';
import 'package:flora_orm/src/models/column_definition.dart';
import 'package:flora_orm/src/models/orm_order.dart';
import 'package:flora_orm/src/models/filter.dart';
import 'package:uuid/uuid.dart';

class Args<TEntity extends IEntity> {
  Args({
    required this.t,
    required this.maps,
    required this.isolateArgs,
    required this.onIsolatePreMap,
  });

  final IEntity t;
  final List<Map<String, dynamic>> maps;

  final Map<String, dynamic>? isolateArgs;
  void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap;
}

List<IEntity> entitiesFromMap<TEntity extends IEntity>(Args args) {
  List<TEntity> entities = [];
  args.onIsolatePreMap?.call(args.isolateArgs);
  for (final item in args.maps) {
    entities.add(args.t.load(item) as TEntity);
  }
  return entities;
}

InsertPrep<IEntity> wInsertOrUpdate(IEntity item) {
  if (item.id == null) item = item.copyWith(id: const Uuid().v4());
  item = item.updateDates();
  return InsertPrep(entity: item, map: item.toDb());
}

List<InsertPrep<TEntity>> wInsertOrUpdateList<TEntity extends IEntity>(
    Iterable<TEntity> items) {
  List<InsertPrep<TEntity>> resultItems = [];
  for (var item in items) {
    if (item.id == null) item = item.copyWith(id: const Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    resultItems.add(InsertPrep(entity: item, map: item.toDb()));
  }
  return resultItems;
}

class InsertPrep<TEntity extends IEntity> {
  InsertPrep({required this.entity, required this.map});
  final TEntity entity;
  final Map<String, dynamic> map;
}

class BaseOrmEngine<TEntity extends IEntity, TMeta extends EntityMeta<TEntity>,
        TDbContext extends BaseContext<TEntity>>
    extends OrmEngine<TEntity, TMeta, TDbContext> {
  const BaseOrmEngine(super.t,
      {required super.dbContext, required super.useIsolateDefault});
  @override
  BaseContext get dbContext => super.dbContext as BaseContext;

  @override
  Future<TEntity?> insert(
    TEntity item, {
    final bool? useIsolate,
  }) async {
    final result = await insertList([item], useIsolate: useIsolate);
    if (result?.isNotEmpty == true) {
      return result?.first;
    }
    return null;
  }

  @override
  Future<List<TEntity>?> insertList(
    Iterable<TEntity> items, {
    final bool? useIsolate,
  }) async {
    final db = await dbContext.database;
    List<TEntity>? result;
    List<TEntity> updatedItems = <TEntity>[];
    final spawnIsolate = useIsolate ?? useIsolateDefault;
    final response = !spawnIsolate
        ? wInsertOrUpdateList(items)
        : await compute(wInsertOrUpdateList, items);

    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var element in response) {
        batch.insert(element.entity.meta.tableName, element.map,
            conflictAlgorithm: ConflictAlgorithm.abort);
        updatedItems.add(element.entity as TEntity);
      }
      result = await _finishBatch(batch, updatedItems);
    });
    return result;
  }

  @override
  Future<TEntity?> insertOrUpdate(
    TEntity item, {
    final bool? useIsolate,
  }) async {
    final result = await insertOrUpdateList([item], useIsolate: useIsolate);
    if (result?.isNotEmpty == true) {
      return result?.first;
    }
    return null;
  }

  @override
  Future<List<TEntity>?> insertOrUpdateList(
    Iterable<TEntity> items, {
    final bool? useIsolate,
  }) async {
    final db = await dbContext.database;
    List<TEntity>? result;
    List<TEntity> updatedItems = <TEntity>[];

    final spawnIsolate = useIsolate ?? useIsolateDefault;
    final response = !spawnIsolate
        ? wInsertOrUpdateList(items)
        : await compute(wInsertOrUpdateList, items);
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var element in response) {
        updatedItems.add(element.entity as TEntity);
        batch.insert(element.entity.meta.tableName, element.map,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      result = await _finishBatch(batch, updatedItems);
    });
    return result;
  }

  @override
  Future<TEntity?> firstWhereOrNull({
    Iterable<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    required Filter Function(TMeta t) where,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<TEntity> maps = await query(
      where: where,
      columns: columns ?? (t) => t.columns,
      limit: 1,
      offset: offset,
      orderBy: orderBy,
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> firstWhereOrNullMap({
    Iterable<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    required Filter Function(TMeta t) where,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<Map<String, dynamic>> maps = await queryMap(
      where: where,
      columns: columns ?? (t) => t.columns,
      limit: 1,
      offset: offset,
      orderBy: orderBy,
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  @override
  Future<T> getSum<T>({
    required ColumnDefinition Function(TMeta t) column,
    Filter Function(TMeta t)? where,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<Map> result = await rawQuery(
      where,
      'SELECT SUM (${column(t).name}) FROM ${t.tableName}',
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
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
    required Iterable<ColumnDefinition> Function(TMeta t) columns,
    Filter Function(TMeta t)? where,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final cols = columns(t).map((e) => e.name).join(' * ');
    List<Map> result = await rawQuery(
      where,
      'SELECT SUM ($cols) FROM ${t.tableName}',
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
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
  Future<List<TEntity>> where({
    Iterable<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<TEntity> maps = await query(
      where: filter,
      limit: limit,
      offset: offset,
      columns: columns ?? (t) => t.columns,
      orderBy: orderBy,
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
    if (maps.isNotEmpty) {
      return maps;
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> whereMap({
    Iterable<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<Map<String, Object?>> maps = await queryMap(
      where: filter,
      limit: limit,
      offset: offset,
      columns: columns ?? (t) => t.columns,
      orderBy: orderBy,
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
    if (maps.isNotEmpty) {
      return maps;
    }
    return [];
  }

  Future<List<TEntity>> _finishBatch(
      Batch batch, Iterable<TEntity> items) async {
    var result = await batch.commit(noResult: false, continueOnError: true);
    List<TEntity> inserted = <TEntity>[];
    var indx = 0;
    for (var element in result) {
      if (element is int && element > 0) {
        inserted.add(items.elementAt(indx));
      }
      indx++;
    }
    return inserted;
  }

  @override
  Future<int> getCount({
    Filter Function(TMeta t)? where,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<Map<String, Object?>> result = await rawQuery(
      where,
      'SELECT COUNT (*) FROM ${t.tableName}',
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
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
    final Filter Function(TMeta t)? where,
    final bool? useIsolate,
    final bool? all,
  }) async {
    assert(all == true || where != null,
        'Either provide where query or specify all = true to delete all.');
    final db = await dbContext.database;
    final formattedQuery = where != null
        ? await whereString(
            where,
            useIsolate,
          )
        : null;
    return await db.transaction<int>((txn) async {
      var batch = txn.batch();
      batch.delete(
        t.tableName,
        where: formattedQuery?.filter,
        whereArgs: formattedQuery?.whereArgs,
      );
      var result = await batch.commit(noResult: false, continueOnError: true);
      if (result.isEmpty) {
        return 0;
      }
      final res = result[0];
      if (res is int) {
        return res;
      }
      return 0;
    });
  }

  @override
  Future<int> update({
    required Filter Function(TMeta t) where,
    TEntity? entity,
    Map<ColumnDefinition, dynamic> Function(TMeta t)? columnValues,
    final bool? useIsolate,
  }) async {
    assert(entity != null || columnValues != null);
    final db = await dbContext.database;
    final formattedQuery = await whereString(where, useIsolate);
    var createdAt = entity?.createdAt;
    if (entity == null) {
      final res = await firstWhereOrNullMap(
          where: where, columns: (t) => [t.createdAt]);
      if (res?.containsKey(t.createdAt.name) == true) {
        createdAt = DateTime.parse(res![t.createdAt.name]);
      }
    }
    entity = (entity ?? mType).updateDates(createdAt: createdAt) as TEntity;
    final update = columnValues != null
        ? entity.toStorageJson(columnValues: columnValues(t))
        : entity.toDb();
    return await db.update(
      t.tableName,
      update,
      where: formattedQuery.filter,
      whereArgs: formattedQuery.whereArgs,
    );
  }

  @override
  @protected
  Future<List<TEntity>> query({
    Filter Function(TMeta t)? where,
    Iterable<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<Map<String, dynamic>> maps;
    final db = await dbContext.database;
    final cols1 = columns?.call(t);
    if (cols1 == null) {
      throw ArgumentError('no columns supplied');
    }
    List<String> cols = [];
    for (var element in cols1) {
      cols.add(element.name);
    }
    if (cols.isEmpty) {
      throw ArgumentError('no columns supplied');
    }
    String? orderByFilter = orderBy
        ?.call(t)
        ?.map((e) =>
            '${e.column.name} ${e.direction == OrderDirection.desc ? ' DESC' : ''}')
        .join(',');

    if (where == null) {
      maps = await db.query(
        t.tableName,
        columns: cols,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    } else {
      final formattedQuery = await whereString(where, useIsolate);
      maps = await db.query(
        t.tableName,
        columns: cols,
        where: formattedQuery.filter,
        whereArgs: formattedQuery.whereArgs,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    }
    final spawnIsolate = useIsolate ?? useIsolateDefault;
    final args = Args<TEntity>(
      t: mType.copyWith(),
      maps: maps,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
    if (!spawnIsolate) {
      return entitiesFromMap(args).map<TEntity>((e) => e as TEntity).toList();
    }
    final result = await compute(entitiesFromMap, args);
    return result.map<TEntity>((e) => e as TEntity).toList();
  }

  @override
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    Filter Function(TMeta t)? where,
    Iterable<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<Map<String, dynamic>> maps;
    final db = await dbContext.database;
    final cols1 = columns?.call(t);
    if (cols1 == null) {
      throw ArgumentError('no columns supplied');
    }
    List<String> cols = [];
    for (var element in cols1) {
      cols.add(element.name);
    }
    if (cols.isEmpty) {
      throw ArgumentError('no columns supplied');
    }
    String? orderByFilter = orderBy
        ?.call(t)
        ?.map((e) =>
            '${e.column.name} ${e.direction == OrderDirection.desc ? ' DESC' : ''}')
        .join(',');

    if (where == null) {
      maps = await db.query(
        t.tableName,
        columns: cols,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    } else {
      final formattedQuery = await whereString(where, useIsolate);
      maps = await db.query(
        t.tableName,
        columns: cols,
        where: formattedQuery.filter,
        whereArgs: formattedQuery.whereArgs,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    }
    return maps;
  }

  @override
  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TMeta t)? where,
    String query, {
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final db = await dbContext.database;
    if (where == null) {
      return await db.rawQuery(query);
    } else {
      final formattedQuery = await whereString(where, useIsolate);
      return await db.rawQuery(
          '$query WHERE ${formattedQuery.filter}', formattedQuery.whereArgs);
    }
  }

  @override
  List<Object?> get props => [dbContext];
}

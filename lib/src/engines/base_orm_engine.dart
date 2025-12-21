import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/context/sqflite_store_context_base.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:uuid/uuid.dart';

class Args<TModel extends ModelBase> {
  Args({
    required this.t,
    required this.maps,
    required this.isolateArgs,
    required this.onIsolatePreMap,
  });

  final ModelBase t;
  final List<Map<String, dynamic>> maps;

  final Map<String, dynamic>? isolateArgs;
  void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap;
}

List<ModelBase> entitiesFromMap<TModel extends ModelBase>(Args args) {
  final entities = <TModel>[];
  args.onIsolatePreMap?.call(args.isolateArgs);
  for (final item in args.maps) {
    entities.add(args.t.load(item) as TModel);
  }
  return entities;
}

InsertPrep<ModelBase> wInsertOrUpdate(ModelBase item) {
  var copy = item;
  if (copy.id == null) copy = copy.copyWith(id: const Uuid().v4());
  copy = copy.updateDates();
  return InsertPrep(model: copy, map: copy.toDb());
}

List<InsertPrep<TModel>> wInsertOrUpdateList<TModel extends ModelBase>(
  Iterable<TModel> items,
) {
  final resultItems = <InsertPrep<TModel>>[];
  for (var item in items) {
    if (item.id == null) item = item.copyWith(id: const Uuid().v4()) as TModel;
    item = item.updateDates() as TModel;
    resultItems.add(InsertPrep(model: item, map: item.toDb()));
  }
  return resultItems;
}

class InsertPrep<TModel extends ModelBase> {
  InsertPrep({required this.model, required this.map});
  final TModel model;
  final Map<String, dynamic> map;
}

class BaseOrmEngine<TModel extends ModelBase, TMeta extends ModelMeta<TModel>,
        TStoreContext extends StoreContext<TModel>>
    extends OrmEngine<TModel, TMeta, TStoreContext> {
  const BaseOrmEngine(
    super.t, {
    required super.dbContext,
    required super.useIsolateDefault,
  });
  @override
  SqfliteStoreContextBase get dbContext =>
      super.dbContext as SqfliteStoreContextBase;

  @override
  Future<TModel?> insert(TModel item, {bool? useIsolate}) async {
    final result = await insertList([item], useIsolate: useIsolate);
    if (result != null && result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  @override
  Future<List<TModel>?> insertList(
    Iterable<TModel> items, {
    bool? useIsolate,
  }) async {
    final db = await dbContext.database;
    List<TModel>? result;
    final updatedItems = <TModel>[];
    final spawnIsolate = useIsolate ?? useIsolateDefault;
    final response = !spawnIsolate
        ? wInsertOrUpdateList(items)
        : await compute(wInsertOrUpdateList, items);

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final element in response) {
        batch.insert(
          element.model.meta.tableName,
          element.map,
          conflictAlgorithm: ConflictAlgorithm.abort,
        );
        updatedItems.add(element.model as TModel);
      }
      result = await _finishBatch(batch, updatedItems);
    });
    return result;
  }

  @override
  Future<TModel?> insertOrUpdate(TModel item, {bool? useIsolate}) async {
    final result = await insertOrUpdateList([item], useIsolate: useIsolate);
    if (result != null && result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  @override
  Future<List<TModel>?> insertOrUpdateList(
    Iterable<TModel> items, {
    bool? useIsolate,
  }) async {
    final db = await dbContext.database;
    List<TModel>? result;
    final updatedItems = <TModel>[];

    final spawnIsolate = useIsolate ?? useIsolateDefault;
    final response = !spawnIsolate
        ? wInsertOrUpdateList(items)
        : await compute(wInsertOrUpdateList, items);
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final element in response) {
        updatedItems.add(element.model as TModel);
        batch.insert(
          element.model.meta.tableName,
          element.map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      result = await _finishBatch(batch, updatedItems);
    });
    return result;
  }

  @override
  Future<TModel?> firstWhereOrNull(
    Filter Function(TMeta t) where, {
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final maps = await query(
      where: where,
      select: select ?? (t) => t.columns,
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
  Future<Map<String, dynamic>?> firstWhereOrNullMap(
    Filter Function(TMeta t) where, {
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final maps = await queryMap(
      where: where,
      select: select ?? (t) => t.columns,
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
    required ColumnDefinition<TModel, dynamic> Function(TMeta t) column,
    Filter Function(TMeta t)? where,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final List<Map<String, dynamic>> result = await rawQuery(
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
    required Iterable<ColumnDefinition<TModel, dynamic>> Function(TMeta t)
        select,
    Filter Function(TMeta t)? where,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final cols = select(t).map((e) => e.name).join(' * ');
    final List<Map<String, dynamic>> result = await rawQuery(
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
  Future<List<TModel>> all({
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    return _where(
      select: select,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
  }

  @override
  Future<List<TModel>> where(
    Filter Function(TMeta t)? filter, {
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    return _where(
      select: select,
      orderBy: orderBy,
      filter: filter,
      limit: limit,
      offset: offset,
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
  }

  Future<List<TModel>> _where({
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final maps = await query(
      where: filter,
      limit: limit,
      offset: offset,
      select: select ?? (t) => t.columns,
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
  Future<List<Map<String, dynamic>>> whereMap(
    Filter Function(TMeta t)? filter, {
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    return _whereMap(
      select: select,
      orderBy: orderBy,
      filter: filter,
      limit: limit,
      offset: offset,
      useIsolate: useIsolate,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
  }

  Future<List<Map<String, dynamic>>> _whereMap({
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final List<Map<String, Object?>> maps = await queryMap(
      where: filter,
      limit: limit,
      offset: offset,
      select: select ?? (t) => t.columns,
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

  Future<List<TModel>> _finishBatch(Batch batch, Iterable<TModel> items) async {
    final result = await batch.commit(noResult: false, continueOnError: false);
    final inserted = <TModel>[];
    var indx = 0;
    for (final element in result) {
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
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final result = await rawQuery(
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
    Filter Function(TMeta t)? where,
    bool? useIsolate,
    bool all = false,
  }) async {
    assert(
      all || where != null,
      'Either provide where query or specify all = true to delete all.',
    );
    final db = await dbContext.database;
    final formattedQuery =
        where != null ? await whereString(where, useIsolate: useIsolate) : null;
    return db.transaction<int>((txn) async {
      final batch = txn.batch()
        ..delete(
          t.tableName,
          where: formattedQuery?.filter,
          whereArgs: formattedQuery?.whereArgs,
        );
      final result = await batch.commit(
        noResult: false,
        continueOnError: false,
      );
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
    TModel? model,
    Map<ColumnDefinition<TModel, dynamic>, dynamic> Function(TMeta t)?
        columnValues,
    bool? useIsolate,
  }) async {
    assert(
      model != null || columnValues != null,
      'model and columnValues cannot be both null',
    );
    final db = await dbContext.database;
    final formattedQuery = await whereString(where, useIsolate: useIsolate);
    var createdAt = model?.createdAt;
    if (model == null) {
      final res = await firstWhereOrNullMap(
        where,
        select: (t) => [t.createdAt],
      );
      if (res != null && res.containsKey(t.createdAt.name)) {
        createdAt = DateTime.parse(res[t.createdAt.name] as String);
      }
    }
    model = (model ?? mType).updateDates(createdAt: createdAt) as TModel;
    final update = columnValues != null
        ? (model as Model).toStorageJson(columnValues: columnValues(t))
        : model.toDb();
    return db.update(
      t.tableName,
      update,
      where: formattedQuery.filter,
      whereArgs: formattedQuery.whereArgs,
    );
  }

  @override
  @protected
  Future<List<TModel>> query({
    Filter Function(TMeta t)? where,
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<Map<String, dynamic>> maps;
    final db = await dbContext.database;
    final customSelect = select?.call(t);
    if (customSelect == null) {
      throw ArgumentError('no select columns supplied');
    }
    final selectColumns = <String>[];
    for (final element in customSelect) {
      selectColumns.add(element.name);
    }
    if (selectColumns.isEmpty) {
      throw ArgumentError('no select columns supplied');
    }
    final orderByFilter = orderBy
        ?.call(t)
        ?.map((e) => '${e.column.name} ${e.direction.sortStr}')
        .join(',');

    if (where == null) {
      maps = await db.query(
        t.tableName,
        columns: selectColumns,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    } else {
      final formattedQuery = await whereString(where, useIsolate: useIsolate);
      maps = await db.query(
        t.tableName,
        columns: selectColumns,
        where: formattedQuery.filter,
        whereArgs: formattedQuery.whereArgs,
        orderBy: orderByFilter,
        limit: limit,
        offset: offset,
      );
    }
    final spawnIsolate = useIsolate ?? useIsolateDefault;
    final args = Args<TModel>(
      t: mType.copyWith(),
      maps: maps,
      isolateArgs: isolateArgs,
      onIsolatePreMap: onIsolatePreMap,
    );
    if (!spawnIsolate) {
      return entitiesFromMap(args).map<TModel>((e) => e as TModel).toList();
    }
    final result = await compute(entitiesFromMap, args);
    return result.map<TModel>((e) => e as TModel).toList();
  }

  @override
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    Filter Function(TMeta t)? where,
    Iterable<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    List<Map<String, dynamic>> maps;
    final db = await dbContext.database;
    final cols1 = select?.call(t);
    if (cols1 == null) {
      throw ArgumentError('no select columns supplied');
    }
    final cols = <String>[];
    for (final element in cols1) {
      cols.add(element.name);
    }
    if (cols.isEmpty) {
      throw ArgumentError('no select columns supplied');
    }
    final orderByFilter = orderBy
        ?.call(t)
        ?.map((e) => '${e.column.name} ${e.direction.sortStr}')
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
      final formattedQuery = await whereString(where, useIsolate: useIsolate);
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
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    final db = await dbContext.database;
    if (where == null) {
      return db.rawQuery(query);
    } else {
      final formattedQuery = await whereString(where, useIsolate: useIsolate);
      return db.rawQuery(
        '$query WHERE ${formattedQuery.filter}',
        formattedQuery.whereArgs,
      );
    }
  }

  @override
  List<Object?> get props => [dbContext];
}

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatlacas_sqflite_storage/sql.dart';
import 'package:tatlacas_sqflite_storage/src/base_storage.dart';
import 'package:tatlacas_sqflite_storage/src/shared_preference/shared_preference_context.dart';
import 'package:uuid/uuid.dart';
import 'package:worker_manager/worker_manager.dart';

class SharedPreferenceStorage<TEntity extends IEntity>
    extends BaseStorage<TEntity, SharedPreferenceContext> {
  @protected
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  SharedPreferenceStorage(TEntity t,
      {required SharedPreferenceContext dbContext})
      : super(t, dbContext: dbContext);

  @protected
  Future<String?> read({required String key}) async {
    return (await prefs).getString(key);
  }

  @protected
  Future<void> write(
      {required String key,
      required String? value,
      Map<String, dynamic>? additionalData}) async {
    await (await prefs).setString(key, value ?? '');
  }

  @protected
  Future<void> deletePref({required String key}) async {
    await (await prefs).remove(key);
  }

  @override
  Future<TEntity?> insert(
    TEntity item, {
    final bool? useIsolate,
    final WorkPriority priority = WorkPriority.immediately,
  }) async {
    if (item.id == null) item = item.copyWith(id: Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final json = jsonEncode(item.toMap());
    await write(key: item.id!, value: json);
    return item;
  }

  @override
  Future<TEntity?> getEntity({
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required SqlWhere Function(TEntity t) where,
    int? offset,
    final bool? useIsolate,
    final WorkPriority priority = WorkPriority.immediately,
  }) async {
    return null;
  }

  @override
  Future<List<TEntity>?> insertList(Iterable<TEntity> items) async {
    return [];
  }

  @override
  Future<TEntity?> insertOrUpdate(
    TEntity item, {
    final bool? useIsolate,
    final WorkPriority priority = WorkPriority.immediately,
  }) async {
    if (item.id == null) item = item.copyWith(id: Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final json = jsonEncode(item.toMap());
    await write(key: item.id!, value: json);
    return item;
  }

  @override
  Future<List<TEntity>?> insertOrUpdateList(Iterable<TEntity> items) async {
    return [];
  }

  @override
  Future<int> delete({
    final SqlWhere Function(TEntity t)? where,
    final bool? useIsolate,
    final WorkPriority priority = WorkPriority.immediately,
  }) async {
    final item = where == null
        ? null
        : where(t)
            .filters
            .where((element) => element.column?.name == 'id')
            .toList();
    if (item != null && item.isNotEmpty == true) {
      await (await prefs).remove(item[0].value);
      return 1;
    }
    return 0;
  }

  @override
  Future<int> update({
    required SqlWhere Function(TEntity t) where,
    TEntity? entity,
    Map<SqlColumn, dynamic> Function(TEntity t)? columnValues,
    final bool? useIsolate,
    final WorkPriority priority = WorkPriority.immediately,
  }) async {
    var query = where(t)
        .filters
        .where((element) => element.column?.name == 'id')
        .toList();
    if (query.isNotEmpty == true) {
      var createdAt = entity?.createdAt;
      if (entity == null) {
        final res = await getEntityMap(
            where: where, columns: (t) => [t.columnCreatedAt]);
        if (res?.containsKey(t.columnCreatedAt.name) == true) {
          createdAt = res![t.columnCreatedAt.name];
        }
      }
      entity = (entity ?? t).updateDates(createdAt: createdAt) as TEntity;
      final update = columnValues != null
          ? entity.toStorageJson(columnValues: columnValues(t))
          : entity.toMap();
      final json = jsonEncode(update);
      await write(key: query[0].value, value: json);
      return 1;
    }
    return 0;
  }

  @override
  Future<List<TEntity>> query({
    SqlWhere Function(TEntity t)? where,
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
    final WorkPriority priority = WorkPriority.immediately,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    SqlWhere Function(TEntity t)? where,
    String query, {
    final bool? useIsolate,
    final WorkPriority priority = WorkPriority.immediately,
  }) async {
    return [];
  }
}

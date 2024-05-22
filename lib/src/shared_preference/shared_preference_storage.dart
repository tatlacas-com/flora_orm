import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatlacas_orm/tatlacas_orm.dart';
import 'package:tatlacas_orm/src/engines/base_engine.dart';
import 'package:tatlacas_orm/src/shared_preference/shared_preference_context.dart';
import 'package:uuid/uuid.dart';

class SharedPreferenceStorage<TEntity extends IEntity>
    extends BaseEngine<TEntity, SharedPreferenceContext> {
  SharedPreferenceStorage(super.t,
      {required super.dbContext, super.useIsolateDefault = true});
  @protected
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

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
  }) async {
    if (item.id == null) item = item.copyWith(id: const Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final json = jsonEncode(item.toMap());
    await write(key: item.id!, value: json);
    return item;
  }

  @override
  Future<TEntity?> getEntity({
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required Filter Function(TEntity t) filter,
    int? offset,
    final bool? useIsolate,
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
  }) async {
    if (item.id == null) item = item.copyWith(id: const Uuid().v4()) as TEntity;
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
    final Filter Function(TEntity t)? filter,
    final bool? useIsolate,
  }) async {
    final item = filter == null
        ? null
        : filter(t)
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
    required Filter Function(TEntity t) filter,
    TEntity? entity,
    Map<SqlColumn, dynamic> Function(TEntity t)? columnValues,
    final bool? useIsolate,
  }) async {
    var query = filter(t)
        .filters
        .where((element) => element.column?.name == 'id')
        .toList();
    if (query.isNotEmpty == true) {
      var createdAt = entity?.createdAt;
      if (entity == null) {
        final res = await getEntityMap(
            filter: filter, columns: (t) => [t.meta.createdAt]);
        if (res?.containsKey(t.meta.createdAt.name) == true) {
          createdAt = res![t.meta.createdAt.name];
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
    Filter Function(TEntity t)? filter,
    Iterable<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TEntity t)? filter,
    String query, {
    final bool? useIsolate,
  }) async {
    return [];
  }
}

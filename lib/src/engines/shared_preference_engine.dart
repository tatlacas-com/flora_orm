import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/engines/base_orm_engine.dart';
import 'package:flora_orm/src/contexts/shared_preference_context.dart';
import 'package:uuid/uuid.dart';

class SharedPreferenceEngine<TEntity extends IEntity,
        TMeta extends EntityMeta<TEntity>>
    extends BaseOrmEngine<TEntity, TMeta, SharedPreferenceContext<TEntity>> {
  SharedPreferenceEngine(super.t,
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
    final result = await insertList([item], useIsolate: useIsolate);
    if (result?.isNotEmpty == true) {
      return result?.first;
    }
    return null;
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
    return null;
  }

  @override
  Future<List<TEntity>?> insertList(
    Iterable<TEntity> items, {
    final bool? useIsolate,
  }) async {
    List<TEntity> result = [];
    for (var item in items) {
      if (item.id == null) {
        item = item.copyWith(id: const Uuid().v4()) as TEntity;
      }
      item = await _saveItem(item, true);
      result.add(item);
    }
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
    List<TEntity> result = [];
    for (var item in items) {
      if (item.id == null) {
        item = item.copyWith(id: const Uuid().v4()) as TEntity;
      }
      item = await _saveItem(item);
      result.add(item);
    }
    return result;
  }

  Future<TEntity> _saveItem(TEntity item, [bool checkExisting = false]) async {
    if (checkExisting) {
      final curr = await read(key: item.id!);
      if (curr != null) {
        throw Exception('Already exists');
      }
    }
    item = item.updateDates() as TEntity;
    final json = jsonEncode(item.toMap());
    await write(key: item.id!, value: json);
    return item;
  }

  @override
  Future<int> delete({
    final Filter Function(TMeta t)? where,
    final bool? useIsolate,
    final bool? all,
  }) async {
    assert(all == true || where != null,
        'Either provide where query or specify all = true to delete all.');

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
    required Filter Function(TMeta t) where,
    TEntity? entity,
    Map<ColumnDefinition, dynamic> Function(TMeta t)? columnValues,
    final bool? useIsolate,
  }) async {
    var query = where(t)
        .filters
        .where((element) => element.column?.name == 'id')
        .toList();
    if (query.isNotEmpty == true) {
      var createdAt = entity?.createdAt;
      if (entity == null) {
        final res = await firstWhereOrNullMap(
            where: where, columns: (t) => [t.createdAt]);
        if (res?.containsKey(t.createdAt.name) == true) {
          createdAt = res![t.createdAt.name];
        }
      }
      entity = (entity ?? mType).updateDates(createdAt: createdAt) as TEntity;
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
    Filter Function(TMeta t)? where,
    Iterable<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TMeta t)? where,
    String query, {
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    return [];
  }
}

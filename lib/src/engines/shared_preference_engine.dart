import 'package:collection/collection.dart';
import 'package:flora_orm/src/models/orm.dart';
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
  Future<Map<String, dynamic>?> getItems() async {
    final items = (await prefs).getString(t.tableName);
    if (items == null) {
      return null;
    }
    return jsonDecode(items) as Map<String, dynamic>;
  }

  @protected
  Future<Map<String, dynamic>?> read({required String key}) async {
    final json = await getItems();
    if (json == null) {
      return null;
    }
    return json[key] as Map<String, dynamic>?;
  }

  @protected
  Future<void> write(
      {required String key,
      required Map<String, dynamic> value,
      Map<String, dynamic>? additionalData}) async {
    Map<String, dynamic> items = await getItems() ?? {};
    items[key] = value;
    await (await prefs).setString(t.tableName, jsonEncode(items));
  }

  @protected
  Future<void> deletePref({required String key}) async {
    Map<String, dynamic> items = await getItems() ?? {};
    items.remove(key);
    await (await prefs).setString(t.tableName, jsonEncode(items));
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
    Map<String, dynamic> records = await getItems() ?? {};
    final filters = where(t).filters;
    final res = records.entries.firstWhereOrNull(
      (element) {
        return _where(element, filters);
      },
    );
    if (res != null) {
      return mType.load(res.value as Map<String, dynamic>) as TEntity;
    }
    return null;
  }

  bool _where(
      MapEntry<String, dynamic> element, List<FilterCondition> filters) {
    var included = false;
    List<bool> includedList = [];
    List<String> operators = [];
    final value = element.value as Map<String, dynamic>;
    for (final filter in filters) {
      final column = filter.column?.name ?? '';
      switch (filter.condition) {
        case OrmCondition.equalTo:
          included = value[column] == filter.value;
          break;
        case OrmCondition.notEqualTo:
          included = value[column] != filter.value;
          break;
        case OrmCondition.lessThan:
          included = (value[column] as num? ?? double.infinity) < filter.value;
          break;
        case OrmCondition.greaterThan:
          included = (value[column] as num? ?? double.infinity) > filter.value;
          break;
        case OrmCondition.lessThanOrEqual:
          included = (value[column] as num? ?? double.infinity) <= filter.value;
          break;
        case OrmCondition.greaterThanOrEqual:
          included = (value[column] as num? ?? double.infinity) >= filter.value;
          break;
        case OrmCondition.between:
          final val = (value[column] as num? ?? double.infinity);
          included = val >= filter.value && val <= filter.secondaryValue;
          break;
        case OrmCondition.isNull:
          included = value[column] == null;
          break;
        case OrmCondition.notNull:
          included = value[column] != null;
          break;
        case OrmCondition.isIn:
          included = (filter.value as List).contains(value[column]);
          break;
        case OrmCondition.like:
          included = _like(filter, value, column);
          break;
        case OrmCondition.notLike:
          included = !_like(filter, value, column);
          break;
        case OrmCondition.notIn:
          included = !(filter.value as List).contains(value[column]);
          break;
        case OrmCondition.notBetween:
          final val = (value[column] as num? ?? double.infinity);
          included = !(val >= filter.value && val <= filter.secondaryValue);
          break;
      }
      includedList.add(included);
      if (filter.and) {
        operators.add('and');
      } else if (filter.or) {
        operators.add('or');
      }
    }
    if (includedList.length > 1) {
      bool finalResult = includedList.first;
      for (int i = 1; i < includedList.length; i++) {
        if (operators[i - 1] == 'and') {
          finalResult = finalResult && includedList[i];
        } else if (operators[i - 1] == 'or') {
          finalResult = finalResult || includedList[i];
        }
      }
      return finalResult;
    }
    return included;
  }

  bool _like(
      FilterCondition filter, Map<String, dynamic> value, String column) {
    final query = filter.value as String;
    final queryVal = query.replaceAll('%', '');
    final val = (value[column] as String? ?? '');
    if (query.startsWith('%') && query.endsWith('%')) {
      return val.contains(queryVal);
    } else if (query.startsWith('%')) {
      return val.endsWith(queryVal);
    } else if (query.endsWith('%')) {
      return val.startsWith(queryVal);
    } else {
      return val.contains(queryVal);
    }
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
    await write(key: item.id!, value: item.toMap());
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

    Map<String, dynamic> items = await getItems() ?? {};
    if (where == null) {
      return items.length;
    }
    final filters = where(t).filters;
    final res = items.entries
        .where(
          (element) {
            return _where(element, filters);
          },
        )
        .map((e) => e.key)
        .toList();

    items.removeWhere((key, value) => res.contains(key));
    await (await prefs).setString(t.tableName, jsonEncode(items));
    return res.length;
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
      await write(key: query[0].value, value: update);
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
    Map<String, dynamic> records = await getItems() ?? {};
    if (where == null) {
      return records.entries
          .map(
            (e) => mType.load(e.value) as TEntity,
          )
          .toList();
    }
    final filters = where(t).filters;
    final res = records.entries.where(
      (element) {
        return _where(element, filters);
      },
    );
    return res
        .map(
          (e) => mType.load(e.value) as TEntity,
        )
        .toList();
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TMeta t)? where,
    String query, {
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    throw UnsupportedError('not supported');
  }
}

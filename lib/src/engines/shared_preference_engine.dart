import 'package:collection/collection.dart';
import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/context/shared_preference_store_context.dart';
import 'package:flora_orm/src/engines/base_orm_engine.dart';
import 'package:flora_orm/src/model/orm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SharedPreferenceEngine<TModel extends ModelBase,
        TMeta extends ModelMeta<TModel>>
    extends BaseOrmEngine<TModel, TMeta, SharedPreferenceStoreContext<TModel>> {
  SharedPreferenceEngine(
    super.t, {
    required super.dbContext,
    super.useIsolateDefault = true,
  });
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
  Future<void> write({
    required String key,
    required Map<String, dynamic> value,
    Map<String, dynamic>? additionalData,
  }) async {
    final items = await getItems() ?? {};
    items[key] = value;
    await (await prefs).setString(t.tableName, jsonEncode(items));
  }

  @protected
  Future<void> deletePref({required String key}) async {
    final items = await getItems() ?? {}
      ..remove(key);
    await (await prefs).setString(t.tableName, jsonEncode(items));
  }

  @override
  Future<TModel?> insert(TModel item, {bool? useIsolate}) async {
    final result = await insertList([item], useIsolate: useIsolate);
    if (result != null && result.isNotEmpty) {
      return result.first;
    }
    return null;
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
    final customSelect = select?.call(t)?.toList();
    if (customSelect != null && customSelect.isEmpty) {
      throw ArgumentError('no select columns supplied');
    }

    final records = await getItems() ?? {};
    final filters = where(t).filters;
    final res = records.entries.firstWhereOrNull((element) {
      return _where(element, filters);
    });
    if (res != null) {
      return mType.load(res.value as Map<String, dynamic>) as TModel;
    }
    return null;
  }

  bool _where(
    MapEntry<String, dynamic> element,
    List<FilterCondition> filters,
  ) {
    var included = false;
    final includedList = <bool>[];
    final operators = <String>[];
    final value = element.value as Map<String, dynamic>;
    for (final filter in filters) {
      final column = filter.column?.name ?? '';
      switch (filter.condition) {
        case OrmCondition.isEqualTo:
          included = value[column] == filter.value;
        case OrmCondition.isNotEqualTo:
          included = value[column] != filter.value;
        case OrmCondition.isLessThan:
          included = (value[column] as num? ?? double.infinity) <
              (filter.value as num);
        case OrmCondition.isGreaterThan:
          included = (value[column] as num? ?? double.infinity) >
              (filter.value as num);
        case OrmCondition.isLessThanOrEqual:
          included = (value[column] as num? ?? double.infinity) <=
              (filter.value as num);
        case OrmCondition.isGreaterThanOrEqual:
          included = (value[column] as num? ?? double.infinity) >=
              (filter.value as num);
        case OrmCondition.isBetween:
          final val = value[column] as num? ?? double.infinity;
          included = val >= (filter.value as num) &&
              val <= (filter.secondaryValue as num);
        case OrmCondition.isNull:
          included = value[column] == null;
        case OrmCondition.isNotNull:
          included = value[column] != null;
        case OrmCondition.isNotEmpty:
          included = value[column] != null && value[column] != '';
        case OrmCondition.isEmpty:
          included = value[column] != null && value[column] == '';
        case OrmCondition.isNullOrEmpty:
          included = value[column] == null || value[column] == '';
        case OrmCondition.isIn:
          included = (filter.value as List).contains(value[column]);
        case OrmCondition.includes:
          included = _like(filter, value, column);
        case OrmCondition.excludes:
          included = !_like(filter, value, column);
        case OrmCondition.isNotIn:
          included = !(filter.value as List).contains(value[column]);
        case OrmCondition.isNotBetween:
          final val = value[column] as num? ?? double.infinity;
          included = !(val >= (filter.value as num) &&
              val <= (filter.secondaryValue as num));
      }
      includedList.add(included);
      if (filter.and) {
        operators.add('and');
      } else if (filter.or) {
        operators.add('or');
      }
    }
    if (includedList.length > 1) {
      var finalResult = includedList.first;
      for (var i = 1; i < includedList.length; i++) {
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
    FilterCondition filter,
    Map<String, dynamic> value,
    String column,
  ) {
    final query = filter.value as String;
    final queryVal = query.replaceAll('%', '');
    final val = value[column] as String? ?? '';
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
  Future<List<TModel>?> insertList(
    Iterable<TModel> items, {
    bool? useIsolate,
  }) async {
    final result = <TModel>[];
    for (var item in items) {
      if (item.id == null) {
        item = item.copyWith(id: const Uuid().v4()) as TModel;
      }
      item = await _saveItem(item, true);
      result.add(item);
    }
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
    final result = <TModel>[];
    for (var item in items) {
      if (item.id == null) {
        item = item.copyWith(id: const Uuid().v4()) as TModel;
      }
      item = await _saveItem(item);
      result.add(item);
    }
    return result;
  }

  Future<TModel> _saveItem(TModel item, [bool checkExisting = false]) async {
    if (checkExisting) {
      final curr = await read(key: item.id!);
      if (curr != null) {
        throw Exception('Already exists');
      }
    }
    final result = item.updateDates() as TModel;
    await write(key: result.id!, value: result.toMap());
    return result;
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

    final items = await getItems() ?? {};
    if (where == null) {
      return items.length;
    }
    final filters = where(t).filters;
    final res = items.entries
        .where((element) {
          return _where(element, filters);
        })
        .map((e) => e.key)
        .toList();

    items.removeWhere((key, value) => res.contains(key));
    await (await prefs).setString(t.tableName, jsonEncode(items));
    return res.length;
  }

  @override
  Future<int> update({
    required Filter Function(TMeta t) where,
    TModel? model,
    Map<ColumnDefinition<TModel, dynamic>, dynamic> Function(TMeta t)?
        columnValues,
    bool? useIsolate,
  }) async {
    final query = where(
      t,
    ).filters.where((element) => element.column?.name == 'id').toList();
    if (query.isNotEmpty == true) {
      var createdAt = model?.createdAt;
      if (model == null) {
        final res = await firstWhereOrNullMap(
          where,
          select: (t) => [t.createdAt],
        );
        if (res != null && res.containsKey(t.createdAt.name)) {
          createdAt = res[t.createdAt.name] as DateTime?;
        }
      }
      model = (model ?? mType).updateDates(createdAt: createdAt) as TModel;
      final update = columnValues != null
          ? (model as Model).toStorageJson(columnValues: columnValues(t))
          : model.toMap();
      await write(key: query[0].value as String, value: update);
      return 1;
    }
    return 0;
  }

  @override
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
    final records = await getItems() ?? {};
    if (where == null) {
      return records.entries
          .map((e) => mType.load(e.value as Map<String, dynamic>) as TModel)
          .toList();
    }
    final filters = where(t).filters;
    final res = records.entries.where((element) {
      return _where(element, filters);
    });
    return res
        .map((e) => mType.load(e.value as Map<String, dynamic>) as TModel)
        .toList();
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TMeta t)? where,
    String query, {
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  }) async {
    throw UnsupportedError('not supported');
  }
}

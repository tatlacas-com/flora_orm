// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flora_orm/src/context/store_context.dart';
import 'package:flora_orm/src/engines/isolates/get_where_string.isolate.dart';
import 'package:flora_orm/src/model/model.dart';
import 'package:flora_orm/src/model/orm.dart';
import 'package:flora_orm/src/model/orm_order.dart';
import 'package:flutter/foundation.dart';

class WhereParams<TModel extends ModelBase, TMeta extends ModelMeta<TModel>> {
  WhereParams({required this.filter, required this.t});
  Filter Function(TMeta t) filter;
  final TMeta t;
}

abstract class OrmEngine<
    TModel extends ModelBase,
    TMeta extends ModelMeta<TModel>,
    TStoreContext extends StoreContext<TModel>> extends Equatable {
  final StoreContext dbContext;
  @protected
  final TModel mType;
  TMeta get t => mType.meta as TMeta;
  final bool useIsolateDefault;

  const OrmEngine(
    this.mType, {
    required this.dbContext,
    this.useIsolateDefault = true,
  });

  Future<TModel?> insert(TModel item, {bool? useIsolate});

  Future<List<TModel>?> insertList(Iterable<TModel> items, {bool? useIsolate});

  Future<TModel?> insertOrUpdate(TModel item, {bool? useIsolate});

  Future<List<TModel>?> insertOrUpdateList(
    Iterable<TModel> items, {
    bool? useIsolate,
  });

  Future<TModel?> firstWhereOrNull(
    Filter Function(TMeta t) where, {
    List<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });
  Future<Map<String, dynamic>?> firstWhereOrNullMap(
    Filter Function(TMeta t) where, {
    List<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<T> getSum<T>({
    required ColumnDefinition<TModel, dynamic> Function(TMeta t) column,
    Filter Function(TMeta t)? where,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<T> getSumProduct<T>({
    required List<ColumnDefinition<TModel, dynamic>> Function(TMeta t) select,
    Filter Function(TMeta t)? where,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<int> getCount({
    Filter Function(TMeta t)? where,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<int> delete({
    Filter Function(TMeta t)? where,
    bool all = false,
    bool? useIsolate,
  });

  Future<int> update({
    required Filter Function(TMeta t) where,
    TModel model,
    Map<ColumnDefinition<TModel, dynamic>, dynamic> Function(TMeta t)?
        columnValues,
    bool? useIsolate,
  });

  @protected
  Future<List<TModel>> query({
    Filter Function(TMeta t)? where,
    List<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    Filter Function(TMeta t)? where,
    List<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<List<TModel>> all({
    List<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<List<TModel>> where(
    Filter Function(TMeta t)? filter, {
    List<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<List<Map<String, dynamic>>> whereMap(
    Filter Function(TMeta t)? filter, {
    List<ColumnDefinition<TModel, dynamic>>? Function(TMeta t)? select,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TMeta t)? where,
    String query, {
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  @protected
  Future<FormattedQuery> whereString(
    Filter Function(TMeta t) filter, {
    bool? useIsolate,
  }) async {
    final sqlWhere = filter(t);
    final spawnIsolate = useIsolate ?? useIsolateDefault;
    if (!spawnIsolate) {
      return getWhereString(sqlWhere);
    }

    return compute(getWhereString, sqlWhere);
  }

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
}

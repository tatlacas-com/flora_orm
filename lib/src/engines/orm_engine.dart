// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flora_orm/src/contexts/store_context.dart';
import 'package:flora_orm/src/engines/isolates/get_where_string.isolate.dart';
import 'package:flora_orm/src/models/entity.dart';
import 'package:flora_orm/src/models/orm.dart';
import 'package:flora_orm/src/models/orm_order.dart';
import 'package:flutter/foundation.dart';

class WhereParams<TEntity extends EntityBase,
    TMeta extends EntityMeta<TEntity>> {
  WhereParams({
    required this.filter,
    required this.t,
  });
  Filter Function(TMeta t) filter;
  final TMeta t;
}

abstract class OrmEngine<
    TEntity extends EntityBase,
    TMeta extends EntityMeta<TEntity>,
    TStoreContext extends StoreContext<TEntity>> extends Equatable {
  final StoreContext dbContext;
  @protected
  final TEntity mType;
  TMeta get t => mType.meta as TMeta;
  final bool useIsolateDefault;

  const OrmEngine(
    this.mType, {
    required this.dbContext,
    this.useIsolateDefault = true,
  });

  Future<TEntity?> insert(
    TEntity item, {
    bool? useIsolate,
  });

  Future<List<TEntity>?> insertList(
    Iterable<TEntity> items, {
    bool? useIsolate,
  });

  Future<TEntity?> insertOrUpdate(
    TEntity item, {
    bool? useIsolate,
  });

  Future<List<TEntity>?> insertOrUpdateList(
    Iterable<TEntity> items, {
    bool? useIsolate,
  });

  Future<TEntity?> firstWhereOrNull(
    Filter Function(TMeta t) where, {
    List<ColumnDefinition<TEntity, dynamic>>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });
  Future<Map<String, dynamic>?> firstWhereOrNullMap(
    Filter Function(TMeta t) where, {
    List<ColumnDefinition<TEntity, dynamic>>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<T> getSum<T>({
    required ColumnDefinition<TEntity, dynamic> Function(TMeta t) column,
    Filter Function(TMeta t)? where,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<T> getSumProduct<T>({
    required List<ColumnDefinition<TEntity, dynamic>> Function(TMeta t) columns,
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
    TEntity entity,
    Map<ColumnDefinition<TEntity, dynamic>, dynamic> Function(TMeta t)?
        columnValues,
    bool? useIsolate,
  });

  @protected
  Future<List<TEntity>> query({
    Filter Function(TMeta t)? where,
    List<ColumnDefinition<TEntity, dynamic>>? Function(TMeta t)? columns,
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
    List<ColumnDefinition<TEntity, dynamic>>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<List<TEntity>> where({
    List<ColumnDefinition<TEntity, dynamic>>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    int? limit,
    int? offset,
    bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<List<Map<String, dynamic>>> whereMap({
    List<ColumnDefinition<TEntity, dynamic>>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
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

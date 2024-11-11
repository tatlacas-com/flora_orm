// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flora_orm/src/engines/isolates/get_where_string.isolate.dart';

import '../contexts/db_context.dart';
import '../models/entity.dart';
import '../models/orm.dart';
import '../models/orm_order.dart';

class WhereParams<TEntity extends IEntity, TMeta extends EntityMeta<TEntity>> {
  WhereParams({
    required this.filter,
    required this.t,
  });
  Filter Function(TMeta t) filter;
  final TMeta t;
}

abstract class OrmEngine<
    TEntity extends IEntity,
    TMeta extends EntityMeta<TEntity>,
    TDbContext extends DbContext<TEntity>> extends Equatable {
  final DbContext dbContext;
  @protected
  final TEntity mType;
  TMeta get t => mType.meta as TMeta;
  final bool useIsolateDefault;

  const OrmEngine(this.mType,
      {required this.dbContext, this.useIsolateDefault = true});

  Future<TEntity?> insert(
    TEntity item, {
    final bool? useIsolate,
  });

  Future<List<TEntity>?> insertList(
    Iterable<TEntity> items, {
    final bool? useIsolate,
  });

  Future<TEntity?> insertOrUpdate(
    TEntity item, {
    final bool? useIsolate,
  });

  Future<List<TEntity>?> insertOrUpdateList(
    Iterable<TEntity> items, {
    final bool? useIsolate,
  });

  Future<TEntity?> firstWhereOrNull({
    List<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    required Filter Function(TMeta t) where,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });
  Future<Map<String, dynamic>?> firstWhereOrNullMap({
    List<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    required Filter Function(TMeta t) where,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<T> getSum<T>({
    required ColumnDefinition Function(TMeta t) column,
    Filter Function(TMeta t)? where,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<T> getSumProduct<T>({
    required List<ColumnDefinition> Function(TMeta t) columns,
    Filter Function(TMeta t)? where,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<int> getCount({
    Filter Function(TMeta t)? where,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<int> delete({
    Filter Function(TMeta t)? where,
    final bool? all,
    final bool? useIsolate,
  });

  Future<int> update({
    required Filter Function(TMeta t) where,
    TEntity entity,
    Map<ColumnDefinition, dynamic> Function(TMeta t)? columnValues,
    final bool? useIsolate,
  });

  @protected
  Future<List<TEntity>> query({
    Filter Function(TMeta t)? where,
    List<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    Filter Function(TMeta t)? where,
    List<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<List<TEntity>> where({
    List<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  Future<List<Map<String, dynamic>>> whereMap({
    List<ColumnDefinition>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    int? limit,
    int? offset,
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TMeta t)? where,
    String query, {
    final bool? useIsolate,
    Map<String, dynamic>? isolateArgs,
    void Function(Map<String, dynamic>? isolateArgs)? onIsolatePreMap,
  });

  @protected
  Future<FormattedQuery> whereString(
    Filter Function(TMeta t) filter,
    bool? useIsolate,
  ) async {
    final sqlWhere = filter(t);
    final spawnIsolate = useIsolate ?? useIsolateDefault;
    if (!spawnIsolate) {
      return getWhereString(sqlWhere);
    }

    return await compute(getWhereString, sqlWhere);
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

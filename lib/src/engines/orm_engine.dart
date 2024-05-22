// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tatlacas_orm/src/engines/isolates/get_where_string.isolate.dart';

import '../contexts/db_context.dart';
import '../models/entity.dart';
import '../models/orm.dart';
import '../models/orm_order.dart';

class WhereParams<TEntity extends IEntity, TMeta extends EntityMeta<TEntity>> {
  WhereParams({
    required this.filter,
    required this.t,
  });
  OrmFilter Function(TMeta t) filter;
  final TMeta t;
}

abstract class SqlEngine<
    TEntity extends IEntity,
    TMeta extends EntityMeta<TEntity>,
    TDbContext extends DbContext<IEntity>> extends Equatable {
  final TDbContext dbContext;
  @protected
  final TEntity mType;
  TMeta get t => mType.meta as TMeta;
  final bool useIsolateDefault;

  const SqlEngine(this.mType,
      {required this.dbContext, this.useIsolateDefault = true});

  Future<TEntity?> insert(
    TEntity item, {
    final bool? useIsolate,
  });

  Future<List<TEntity>?> insertList(Iterable<TEntity> items);

  Future<TEntity?> insertOrUpdate(
    TEntity item, {
    final bool? useIsolate,
  });

  Future<List<TEntity>?> insertOrUpdateList(Iterable<TEntity> items);

  Future<TEntity?> getEntity({
    List<OrmColumn>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    required OrmFilter Function(TMeta t) filter,
    int? offset,
    final bool? useIsolate,
  });
  Future<Map<String, dynamic>?> getEntityMap({
    List<OrmColumn>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    required OrmFilter Function(TMeta t) filter,
    int? offset,
    final bool? useIsolate,
  });

  Future<T> getSum<T>({
    required OrmColumn Function(TMeta t) column,
    OrmFilter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  Future<T> getSumProduct<T>({
    required List<OrmColumn> Function(TMeta t) columns,
    OrmFilter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  Future<int> getCount({
    OrmFilter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  Future<int> delete({
    OrmFilter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  Future<int> update({
    required OrmFilter Function(TMeta t) filter,
    TEntity entity,
    Map<OrmColumn, dynamic> Function(TMeta t)? columnValues,
    final bool? useIsolate,
  });

  @protected
  Future<List<TEntity>> query({
    OrmFilter Function(TMeta t)? filter,
    List<OrmColumn>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  });
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    OrmFilter Function(TMeta t)? filter,
    List<OrmColumn>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  });

  Future<List<TEntity>> getEntities({
    List<OrmColumn>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    OrmFilter Function(TMeta t)? filter,
    final bool? useIsolate,
  });
  Future<List<Map<String, dynamic>>> getEntityMaps({
    List<OrmColumn>? Function(TMeta t)? columns,
    List<OrmOrder>? Function(TMeta t)? orderBy,
    OrmFilter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    OrmFilter Function(TMeta t)? filter,
    String query, {
    final bool? useIsolate,
  });

  @protected
  Future<FormattedQuery> whereString(
    OrmFilter Function(TMeta t) filter,
    bool? useIsolate,
  ) async {
    final sqlWhere = filter(t);
    final spawnIsolate = useIsolate ?? useIsolateDefault;
    if (!spawnIsolate) {
      return getWhereString(sqlWhere);
    }

    return await compute(getWhereString, sqlWhere);
  }
}
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tatlacas_orm/src/engines/isolates/get_where_string.isolate.dart';

import '../contexts/db_context.dart';
import '../models/entity.dart';
import '../models/sql.dart';
import '../models/sql_order.dart';

class WhereParams<TEntity extends IEntity, TMeta extends EntityMeta<TEntity>> {
  WhereParams({
    required this.filter,
    required this.t,
  });
  Filter Function(TMeta t) filter;
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
    List<SqlColumn>? Function(TMeta t)? columns,
    List<SqlOrder>? Function(TMeta t)? orderBy,
    required Filter Function(TMeta t) filter,
    int? offset,
    final bool? useIsolate,
  });
  Future<Map<String, dynamic>?> getEntityMap({
    List<SqlColumn>? Function(TMeta t)? columns,
    List<SqlOrder>? Function(TMeta t)? orderBy,
    required Filter Function(TMeta t) filter,
    int? offset,
    final bool? useIsolate,
  });

  Future<T> getSum<T>({
    required SqlColumn Function(TMeta t) column,
    Filter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  Future<T> getSumProduct<T>({
    required List<SqlColumn> Function(TMeta t) columns,
    Filter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  Future<int> getCount({
    Filter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  Future<int> delete({
    Filter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  Future<int> update({
    required Filter Function(TMeta t) filter,
    TEntity entity,
    Map<SqlColumn, dynamic> Function(TMeta t)? columnValues,
    final bool? useIsolate,
  });

  @protected
  Future<List<TEntity>> query({
    Filter Function(TMeta t)? filter,
    List<SqlColumn>? Function(TMeta t)? columns,
    List<SqlOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  });
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    Filter Function(TMeta t)? filter,
    List<SqlColumn>? Function(TMeta t)? columns,
    List<SqlOrder>? Function(TMeta t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  });

  Future<List<TEntity>> getEntities({
    List<SqlColumn>? Function(TMeta t)? columns,
    List<SqlOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    final bool? useIsolate,
  });
  Future<List<Map<String, dynamic>>> getEntityMaps({
    List<SqlColumn>? Function(TMeta t)? columns,
    List<SqlOrder>? Function(TMeta t)? orderBy,
    Filter Function(TMeta t)? filter,
    final bool? useIsolate,
  });

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TMeta t)? filter,
    String query, {
    final bool? useIsolate,
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
}

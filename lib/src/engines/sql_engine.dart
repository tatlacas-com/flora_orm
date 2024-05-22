// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:tatlacas_orm/src/engines/isolates/get_where_string.isolate.dart';

import '../contexts/db_context.dart';
import '../models/entity.dart';
import '../models/sql.dart';
import '../models/sql_order.dart';

class WhereParams<TEntity extends IEntity> {
  WhereParams({
    required this.filter,
    required this.t,
  });
  Filter Function(TEntity t) filter;
  final TEntity t;
}

abstract class SqlEngine<TEntity extends IEntity,
    TDbContext extends DbContext<IEntity>> extends Equatable {
  final TDbContext dbContext;
  final TEntity t;
  final bool useIsolateDefault;

  const SqlEngine(this.t,
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
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required Filter Function(TEntity t) filter,
    int? offset,
    final bool? useIsolate,
  });
  Future<Map<String, dynamic>?> getEntityMap({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required Filter Function(TEntity t) filter,
    int? offset,
    final bool? useIsolate,
  });

  Future<T> getSum<T>({
    required SqlColumn Function(TEntity t) column,
    Filter Function(TEntity t)? filter,
    final bool? useIsolate,
  });

  Future<T> getSumProduct<T>({
    required List<SqlColumn> Function(TEntity t) columns,
    Filter Function(TEntity t)? filter,
    final bool? useIsolate,
  });

  Future<int> getCount({
    Filter Function(TEntity t)? filter,
    final bool? useIsolate,
  });

  Future<int> delete({
    Filter Function(TEntity t)? filter,
    final bool? useIsolate,
  });

  Future<int> update({
    required Filter Function(TEntity t) filter,
    TEntity entity,
    Map<SqlColumn, dynamic> Function(TEntity t)? columnValues,
    final bool? useIsolate,
  });

  @protected
  Future<List<TEntity>> query({
    Filter Function(TEntity t)? filter,
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  });
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    Filter Function(TEntity t)? filter,
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  });

  Future<List<TEntity>> getEntities({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    Filter Function(TEntity t)? filter,
    final bool? useIsolate,
  });
  Future<List<Map<String, dynamic>>> getEntityMaps({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    Filter Function(TEntity t)? filter,
    final bool? useIsolate,
  });

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    Filter Function(TEntity t)? filter,
    String query, {
    final bool? useIsolate,
  });

  @protected
  Future<FormattedQuery> whereString(
    Filter Function(TEntity t) filter,
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

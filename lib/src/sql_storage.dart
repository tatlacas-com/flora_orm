// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'db_context.dart';
import 'models/entity.dart';
import 'models/sql.dart';
import 'models/sql_order.dart';

class WhereParams<TEntity extends IEntity> {
  WhereParams({
    required this.where,
    required this.t,
  });
  SqlWhere Function(TEntity t) where;
  final TEntity t;
}

dynamic dbValue(dynamic value) {
  var result = value;
  if (value is bool) {
    result = value ? 1 : 0;
  } else if (value is DateTime) {
    result = value.toIso8601String();
  }
  return result;
}

String getCondition(SqlCondition condition) {
  switch (condition) {
    case SqlCondition.equalTo:
      return ' = ? ';
    case SqlCondition.notEqualTo:
      return ' <> ? ';
    case SqlCondition.isNull:
      return ' IS NULL ';
    case SqlCondition.notNull:
      return ' IS NOT NULL ';
    case SqlCondition.lessThan:
      return ' < ? ';
    case SqlCondition.greaterThan:
      return ' > ? ';
    case SqlCondition.greaterThanOrEqual:
      return ' >= ? ';
    case SqlCondition.lessThanOrEqual:
      return ' <= ? ';
    case SqlCondition.between:
      return ' BETWEEN ? AND ? ';
    case SqlCondition.notBetween:
      return ' NOT BETWEEN ? AND ? ';
    case SqlCondition.isIn:
      return ' IN ';
    case SqlCondition.notIn:
      return ' NOT IN ';
    case SqlCondition.like:
      return ' LIKE ? ';
    case SqlCondition.notLike:
      return ' NOT LIKE ? ';
  }
}

FormattedQuery getWhereString<TEntity extends IEntity>(SqlWhere where) {
  StringBuffer stringBuffer = StringBuffer();
  final whereArgs = <dynamic>[];
  for (var element in where.filters) {
    if (element.isBracketOnly) {
      if (element.leftBracket) stringBuffer.write('(');
      if (element.rightBracket) stringBuffer.write(')');
      continue;
    }
    if (element.and) {
      stringBuffer.write(' AND ');
    } else if (element.or) {
      stringBuffer.write(' OR ');
    }
    if (element.leftBracket) stringBuffer.write('(');

    stringBuffer.write(element.column!.name);
    stringBuffer.write(getCondition(element.condition));
    if (element.condition != SqlCondition.isNull &&
        element.condition != SqlCondition.notNull) {
      if ((element.condition == SqlCondition.isIn ||
              element.condition == SqlCondition.notIn) &&
          element.value is List) {
        final args = element.value as List;
        final argsQ = args.map((e) => '?').toList();
        final q = argsQ.join(', ');
        stringBuffer.write('($q)');
        whereArgs.addAll(args);
      } else {
        whereArgs.add(dbValue(element.value));
      }
    }
    if (element.condition == SqlCondition.between ||
        element.condition == SqlCondition.notBetween) {
      whereArgs.add(element.value2);
    }
    if (element.rightBracket) stringBuffer.write(')');
  }
  return FormattedQuery(where: stringBuffer.toString(), whereArgs: whereArgs);
}

abstract class SqlStorage<TEntity extends IEntity,
    TDbContext extends DbContext<IEntity>> extends Equatable {
  final TDbContext dbContext;
  final TEntity t;
  final bool useIsolateDefault;

  const SqlStorage(this.t,
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
    required SqlWhere Function(TEntity t) where,
    int? offset,
    final bool? useIsolate,
  });
  Future<Map<String, dynamic>?> getEntityMap({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required SqlWhere Function(TEntity t) where,
    int? offset,
    final bool? useIsolate,
  });

  Future<T> getSum<T>({
    required SqlColumn Function(TEntity t) column,
    SqlWhere Function(TEntity t)? where,
    final bool? useIsolate,
  });

  Future<T> getSumProduct<T>({
    required List<SqlColumn> Function(TEntity t) columns,
    SqlWhere Function(TEntity t)? where,
    final bool? useIsolate,
  });

  Future<int> getCount({
    SqlWhere Function(TEntity t)? where,
    final bool? useIsolate,
  });

  Future<int> delete({
    SqlWhere Function(TEntity t)? where,
    final bool? useIsolate,
  });

  Future<int> update({
    required SqlWhere Function(TEntity t) where,
    TEntity entity,
    Map<SqlColumn, dynamic> Function(TEntity t)? columnValues,
    final bool? useIsolate,
  });

  @protected
  Future<List<TEntity>> query({
    SqlWhere Function(TEntity t)? where,
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  });
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    SqlWhere Function(TEntity t)? where,
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
    final bool? useIsolate,
  });

  Future<List<TEntity>> getEntities({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    SqlWhere Function(TEntity t)? where,
    final bool? useIsolate,
  });
  Future<List<Map<String, dynamic>>> getEntityMaps({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    SqlWhere Function(TEntity t)? where,
    final bool? useIsolate,
  });

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    SqlWhere Function(TEntity t)? where,
    String query, {
    final bool? useIsolate,
  });

  @protected
  Future<FormattedQuery> whereString(
    SqlWhere Function(TEntity t) where,
    bool? useIsolate,
  ) async {
    final sqlWhere = where(t);
    final spawnIsolate = useIsolate ?? useIsolateDefault;
    if (!spawnIsolate) {
      return getWhereString(sqlWhere);
    }

    return await compute(getWhereString, sqlWhere);
  }
}

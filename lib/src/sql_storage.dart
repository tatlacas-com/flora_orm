import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'db_context.dart';
import 'models/entity.dart';
import 'models/sql.dart';
import 'models/sql_order.dart';

abstract class SqlStorage<TEntity extends IEntity,
    TDbContext extends DbContext<IEntity>> extends Equatable {
  final TDbContext dbContext;
  final TEntity t;

  const SqlStorage(this.t, {required this.dbContext});

  Future<TEntity?> insert(TEntity item);

  Future<List<TEntity>?> insertList(Iterable<TEntity> items);

  Future<TEntity?> insertOrUpdate(TEntity item);

  Future<List<TEntity>?> insertOrUpdateList(Iterable<TEntity> items);

  Future<TEntity?> getEntity({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required SqlWhere Function(TEntity t) where,
    int? offset,
  });
  Future<Map<String, dynamic>?> getEntityMap({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    required SqlWhere Function(TEntity t) where,
    int? offset,
  });

  Future<T> getSum<T>({
    required SqlColumn Function(TEntity t) column,
    SqlWhere Function(TEntity t)? where,
  });

  Future<T> getSumProduct<T>({
    required List<SqlColumn> Function(TEntity t) columns,
    SqlWhere Function(TEntity t)? where,
  });

  Future<int> getCount({
    SqlWhere Function(TEntity t)? where,
  });

  Future<int> delete({
    required SqlWhere Function(TEntity t) where,
  });

  Future<int> update({
    required SqlWhere Function(TEntity t) where,
    TEntity entity,
    Map<SqlColumn, dynamic> Function(TEntity t)? columnValues,
  });

  @protected
  Future<List<TEntity>> query({
    SqlWhere Function(TEntity t)? where,
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
  });
  @protected
  Future<List<Map<String, dynamic>>> queryMap({
    SqlWhere Function(TEntity t)? where,
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    int? limit,
    int? offset,
  });

  Future<List<TEntity>> getEntities({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    SqlWhere Function(TEntity t)? where,
  });
  Future<List<Map<String, dynamic>>> getEntityMaps({
    List<SqlColumn>? Function(TEntity t)? columns,
    List<SqlOrder>? Function(TEntity t)? orderBy,
    SqlWhere Function(TEntity t)? where,
  });

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    SqlWhere Function(TEntity t)? where,
    String query,
  );

  @protected
  FormattedQuery whereString(
    SqlWhere Function(TEntity t) where,
  ) {
    StringBuffer query = StringBuffer();
    final whereArgs = <dynamic>[];
    where(t).filters.forEach((element) {
      if (element.isBracketOnly) {
        if (element.leftBracket) query.write('(');
        if (element.rightBracket) query.write(')');
        return;
      }
      if (element.and)
        query.write(' AND ');
      else if (element.or) query.write(' OR ');
      if (element.leftBracket) query.write('(');

      query.write(element.column!.name);
      query.write(_getCondition(element.condition));
      if (element.condition != SqlCondition.Null &&
          element.condition != SqlCondition.NotNull) {
        if ((element.condition == SqlCondition.In ||
                element.condition == SqlCondition.NotIn) &&
            element.value is List) {
          final args = element.value as List;
          final argsQ = args.map((e) => '?').toList();
          final q = argsQ.join(', ');
          query.write('($q)');
          whereArgs.addAll(args);
        } else
          whereArgs.add(_dbValue(element.value));
      }
      if (element.condition == SqlCondition.Between ||
          element.condition == SqlCondition.NotBetween)
        whereArgs.add(element.value2);
      if (element.rightBracket) query.write(')');
    });
    return FormattedQuery(where: query.toString(), whereArgs: whereArgs);
  }

  dynamic _dbValue(dynamic value) {
    var result = value;
    if (value is bool)
      result = value ? 1 : 0;
    else if (value is DateTime) result = value.toIso8601String();
    return result;
  }

  String _getCondition(SqlCondition condition) {
    switch (condition) {
      case SqlCondition.EqualTo:
        return ' = ? ';
      case SqlCondition.NotEqualTo:
        return ' <> ? ';
      case SqlCondition.Null:
        return ' IS NULL ';
      case SqlCondition.NotNull:
        return ' IS NOT NULL ';
      case SqlCondition.LessThan:
        return ' < ? ';
      case SqlCondition.GreaterThan:
        return ' > ? ';
      case SqlCondition.GreaterThanOrEqual:
        return ' >= ? ';
      case SqlCondition.LessThanOrEqual:
        return ' <= ? ';
      case SqlCondition.Between:
        return ' BETWEEN ? AND ? ';
      case SqlCondition.NotBetween:
        return ' NOT BETWEEN ? AND ? ';
      case SqlCondition.In:
        return ' IN ';
      case SqlCondition.NotIn:
        return ' NOT IN ';
      case SqlCondition.Like:
        return ' LIKE ? ';
      case SqlCondition.NotLike:
        return ' NOT LIKE ? ';
    }
  }
}

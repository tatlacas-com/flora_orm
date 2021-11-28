import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'db_context.dart';
import 'models/entity.dart';

import 'models/sql.dart';
import 'models/sql_order.dart';

abstract class SqlStorage<TEntity extends IEntity, TDbContext extends DbContext<IEntity>>
    extends Equatable {
  final TDbContext dbContext;

  const SqlStorage({required this.dbContext});


  Future<TEntity?> insert(TEntity item);

  Future<List<TEntity>?> insertList(Iterable<TEntity> items);

  Future<TEntity?> insertOrUpdate(TEntity item);

  Future<List<TEntity>?> insertOrUpdateList(Iterable<TEntity> items);

  Future<Map<String,dynamic>?> getEntity(
    TEntity type, {
    List<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
    required SqlWhere where,
  });

  Future<T> getSum<T>(
    TEntity type, {
    required SqlColumn column,
    SqlWhere? where,
  });

  Future<T> getSumProduct<T>(
    TEntity type, {
    required List<SqlColumn> columns,
    SqlWhere? where,
  });

  Future<int?> getCount(
    TEntity type, {
    SqlWhere? where,
  });

  Future<int> delete(
    TEntity type, {
    required SqlWhere where,
  });

  Future<int> update(
    TEntity item, {
    required SqlWhere where,
    Map<SqlColumn, dynamic>? columnValues,
  });

  @protected
  Future<List<Map<String, dynamic>>> query({
    SqlWhere? where,
    required TEntity type,
    List<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
  });

  Future<List<Map<String,dynamic>>> getEntities(
    TEntity type, {
    List<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
    SqlWhere? where,
  });



  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    SqlWhere? where,
    String query,
  );

  @protected
  FormattedQuery whereString(SqlWhere where) {
    StringBuffer query = StringBuffer();
    final whereArgs = <dynamic>[];
    where.filters.forEach((element) {
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
    return  FormattedQuery(where: query.toString(),whereArgs: whereArgs);
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

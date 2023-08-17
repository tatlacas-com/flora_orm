import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'db_context.dart';
import 'models/entity.dart';
import 'models/sql.dart';
import 'models/sql_order.dart';

abstract class SqlStorage<TEntity extends IEntity,
    TDbContext extends DbContext<IEntity>> extends Equatable {
  final TDbContext dbContext;
  final TEntity typeProvider;

  const SqlStorage(this.typeProvider, {required this.dbContext});

  Future<TEntity?> insert(TEntity item);

  Future<List<TEntity>?> insertList(Iterable<TEntity> items);

  Future<TEntity?> insertOrUpdate(TEntity item);

  Future<List<TEntity>?> insertOrUpdateList(Iterable<TEntity> items);

  Future<Map<String, dynamic>?> getEntity({
    List<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
    required SqlWhere Function(TEntity typeProvider) where,
    int? offset,
  });

  Future<T> getSum<T>({
    required SqlColumn column,
    SqlWhere Function(TEntity typeProvider)? where,
  });

  Future<T> getSumProduct<T>({
    required List<SqlColumn> columns,
    SqlWhere Function(TEntity typeProvider)? where,
  });

  Future<int> getCount({
    SqlWhere Function(TEntity typeProvider)? where,
  });

  Future<int> delete({
    required SqlWhere Function(TEntity typeProvider) where,
  });

  Future<int> update({
    required SqlWhere Function(TEntity typeProvider) where,
    TEntity entity,
    Map<SqlColumn, dynamic>? columnValues,
  });

  @protected
  Future<List<Map<String, dynamic>>> query({
    SqlWhere Function(TEntity typeProvider)? where,
    List<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
    int? limit,
    int? offset,
  });

  Future<List<Map<String, dynamic>>> getEntities({
    List<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
    SqlWhere Function(TEntity typeProvider)? where,
  });

  @protected
  Future<List<Map<String, Object?>>> rawQuery(
    SqlWhere Function(TEntity typeProvider)? where,
    String query,
  );

  @protected
  FormattedQuery whereString(
    SqlWhere Function(TEntity typeProvider) where,
  ) {
    StringBuffer query = StringBuffer();
    final whereArgs = <dynamic>[];
    where(typeProvider).filters.forEach((element) {
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

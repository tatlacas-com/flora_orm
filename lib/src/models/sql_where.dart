import 'sql_column.dart';
import 'sql_condition.dart';
import 'sql_where_condition.dart';

class SqlWhere {
  List<SqlWhereCondition> _filters = [];

  List<SqlWhereCondition> get filters => List.unmodifiable(_filters);

  /// [lb] adds left bracket, [rb] adds right bracket
  SqlWhere(SqlColumn column,
      {SqlCondition condition = SqlCondition.EqualTo,
        dynamic value,
        bool lb = false,
        bool rb = false}) {
    this._addFilter(
      column,
      condition: condition,
      value: value,
      lb: lb,
      rb: rb,
    );
  }

  void _addFilter(
      SqlColumn column, {
        SqlCondition condition = SqlCondition.EqualTo,
        dynamic value,
        bool lb = false,
        bool rb = false,
        bool isBracketOnly = false,
        bool and = false,
        bool or = false,
      }) {
    _filters.add(SqlWhereCondition(
      column: column,
      condition: condition,
      value: value,
      leftBracket: lb,
      rightBracket: rb,
      isBracketOnly: isBracketOnly,
      and: and,
      or: or,
    ));
  }

  SqlWhere lb() {
    _filters.add(SqlWhereCondition(leftBracket: true, isBracketOnly: true));
    return this;
  }

  SqlWhere rb() {
    _filters.add(SqlWhereCondition(rightBracket: true, isBracketOnly: true));
    return this;
  }

  SqlWhere and(SqlColumn column,
      {SqlCondition condition = SqlCondition.EqualTo,
        dynamic value,
        bool lb = false,
        bool rb = false}) {
    this._addFilter(
      column,
      condition: condition,
      value: value,
      lb: lb,
      rb: rb,
      and: true,
    );
    return this;
  }

  SqlWhere or(SqlColumn column,
      {SqlCondition condition = SqlCondition.EqualTo,
        dynamic value,
        bool lb = false,
        bool rb = false}) {
    this._addFilter(
      column,
      condition: condition,
      value: value,
      lb: lb,
      rb: rb,
      or: true,
    );
    return this;
  }
}
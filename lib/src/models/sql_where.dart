import 'package:equatable/equatable.dart';

import 'sql_column.dart';
import 'sql_condition.dart';
import 'sql_where_condition.dart';

class SqlWhere extends Equatable {
  /// [lb] adds left bracket, [rb] adds right bracket
  SqlWhere(
    SqlColumn? column, {
    SqlCondition condition = SqlCondition.equalTo,
    dynamic value,
    dynamic value2,
    bool lb = false,
    bool rb = false,
    List<SqlWhereCondition> filters = const [],
  }) {
    if (column != null) {
      this.filters = [
        ...filters,
        _addFilter(
          column,
          condition: condition,
          value: value,
          value2: value2,
          lb: lb,
          rb: rb,
        )
      ];
    } else {
      this.filters = filters;
    }
  }

  // ignore: prefer_const_constructors_in_immutables
  SqlWhere._({this.filters = const []});

  factory SqlWhere.lb() {
    return SqlWhere._(
        filters: [
      const SqlWhereCondition(leftBracket: true, isBracketOnly: true)
    ].toList());
  }
  late final List<SqlWhereCondition> filters;

  SqlWhereCondition _addFilter(
    SqlColumn column, {
    SqlCondition condition = SqlCondition.equalTo,
    dynamic value,
    dynamic value2,
    bool lb = false,
    bool rb = false,
    bool isBracketOnly = false,
    bool and = false,
    bool or = false,
  }) {
    return SqlWhereCondition(
      column: column,
      condition: condition,
      value: value,
      value2: value2,
      leftBracket: lb,
      rightBracket: rb,
      isBracketOnly: isBracketOnly,
      and: and,
      or: or,
    );
  }

  SqlWhere lb() {
    return SqlWhere(null, filters: [
      ...filters,
      const SqlWhereCondition(leftBracket: true, isBracketOnly: true)
    ]);
  }

  SqlWhere rb() {
    return SqlWhere(null, filters: [
      ...filters,
      const SqlWhereCondition(rightBracket: true, isBracketOnly: true)
    ]);
  }

  SqlWhere and(SqlColumn column,
      {SqlCondition condition = SqlCondition.equalTo,
      dynamic value,
      bool lb = false,
      bool rb = false}) {
    return SqlWhere(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        lb: lb,
        rb: rb,
        and: true,
      )
    ]);
  }

  SqlWhere query(SqlColumn column,
      {SqlCondition condition = SqlCondition.equalTo,
      dynamic value,
      bool lb = false,
      bool rb = false}) {
    return SqlWhere(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        lb: lb,
        rb: rb,
      )
    ]);
  }

  SqlWhere or(SqlColumn column,
      {SqlCondition condition = SqlCondition.equalTo,
      dynamic value,
      bool lb = false,
      bool rb = false}) {
    return SqlWhere(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        lb: lb,
        rb: rb,
        or: true,
      )
    ]);
  }

  @override
  List<Object?> get props => [filters];
}

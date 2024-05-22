import 'package:equatable/equatable.dart';

import 'sql_column.dart';
import 'sql_condition.dart';
import 'sql_where_condition.dart';

class Filter extends Equatable {
  /// [lb] adds left bracket, [rb] adds right bracket
  Filter(
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
  Filter._({this.filters = const []});

  factory Filter.lb() {
    return Filter._(
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

  Filter lb() {
    return Filter(null, filters: [
      ...filters,
      const SqlWhereCondition(leftBracket: true, isBracketOnly: true)
    ]);
  }

  Filter rb() {
    return Filter(null, filters: [
      ...filters,
      const SqlWhereCondition(rightBracket: true, isBracketOnly: true)
    ]);
  }

  Filter and(SqlColumn column,
      {SqlCondition condition = SqlCondition.equalTo,
      dynamic value,
      bool lb = false,
      bool rb = false}) {
    return Filter(null, filters: [
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

  Filter filter(
    SqlColumn column, {
    SqlCondition condition = SqlCondition.equalTo,
    dynamic value,
    bool lb = false,
    bool rb = false,
  }) {
    return Filter(null, filters: [
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

  Filter or(SqlColumn column,
      {SqlCondition condition = SqlCondition.equalTo,
      dynamic value,
      bool lb = false,
      bool rb = false}) {
    return Filter(null, filters: [
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

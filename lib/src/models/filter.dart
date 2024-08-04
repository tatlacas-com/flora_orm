import 'package:equatable/equatable.dart';

import 'column_definition.dart';
import 'orm_condition.dart';
import 'filter_condition.dart';

class Filter extends Equatable {
  /// [lb] adds left bracket, [rb] adds right bracket
  Filter(
    ColumnDefinition? column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic secondaryValue,
    bool lb = false,
    bool rb = false,
    List<FilterCondition> filters = const [],
  }) {
    if (column != null) {
      this.filters = [
        ...filters,
        _addFilter(
          column,
          condition: condition,
          value: value,
          secondaryValue: secondaryValue,
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

  factory Filter.startGroup() {
    return Filter._(
        filters: [const FilterCondition(leftBracket: true, isBracketOnly: true)]
            .toList());
  }
  late final List<FilterCondition> filters;

  FilterCondition _addFilter(
    ColumnDefinition column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic secondaryValue,
    bool lb = false,
    bool rb = false,
    bool isBracketOnly = false,
    bool and = false,
    bool or = false,
  }) {
    return FilterCondition(
      column: column,
      condition: condition,
      value: value,
      secondaryValue: secondaryValue,
      leftBracket: lb,
      rightBracket: rb,
      isBracketOnly: isBracketOnly,
      and: and,
      or: or,
    );
  }

  Filter startGroup() {
    return Filter(null, filters: [
      ...filters,
      const FilterCondition(leftBracket: true, isBracketOnly: true)
    ]);
  }

  Filter endGroup() {
    return Filter(null, filters: [
      ...filters,
      const FilterCondition(rightBracket: true, isBracketOnly: true)
    ]);
  }

  Filter and(ColumnDefinition column,
      {OrmCondition condition = OrmCondition.equalTo,
      dynamic value,
      dynamic secondaryValue,
      bool lb = false,
      bool rb = false}) {
    return Filter(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        secondaryValue: secondaryValue,
        lb: lb,
        rb: rb,
        and: true,
      )
    ]);
  }

  Filter filter(
    ColumnDefinition column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic secondaryValue,
    bool lb = false,
    bool rb = false,
  }) {
    return Filter(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        secondaryValue: secondaryValue,
        lb: lb,
        rb: rb,
      )
    ]);
  }

  Filter or(
    ColumnDefinition column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic secondaryValue,
    bool lb = false,
    bool rb = false,
  }) {
    return Filter(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        secondaryValue: secondaryValue,
        lb: lb,
        rb: rb,
        or: true,
      )
    ]);
  }

  @override
  List<Object?> get props => [filters];
}

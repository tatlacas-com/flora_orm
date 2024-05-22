import 'package:equatable/equatable.dart';

import 'orm_column.dart';
import 'orm_condition.dart';
import 'filter_condition.dart';

class Filter extends Equatable {
  /// [lb] adds left bracket, [rb] adds right bracket
  Filter(
    OrmColumn? column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic value2,
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
        filters: [const FilterCondition(leftBracket: true, isBracketOnly: true)]
            .toList());
  }
  late final List<FilterCondition> filters;

  FilterCondition _addFilter(
    OrmColumn column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic value2,
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
      const FilterCondition(leftBracket: true, isBracketOnly: true)
    ]);
  }

  Filter rb() {
    return Filter(null, filters: [
      ...filters,
      const FilterCondition(rightBracket: true, isBracketOnly: true)
    ]);
  }

  Filter and(OrmColumn column,
      {OrmCondition condition = OrmCondition.equalTo,
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
    OrmColumn column, {
    OrmCondition condition = OrmCondition.equalTo,
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

  Filter or(OrmColumn column,
      {OrmCondition condition = OrmCondition.equalTo,
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

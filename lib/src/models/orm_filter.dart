import 'package:equatable/equatable.dart';

import 'orm_column.dart';
import 'orm_condition.dart';
import 'orm_filter_condition.dart';

class OrmFilter extends Equatable {
  /// [lb] adds left bracket, [rb] adds right bracket
  OrmFilter(
    OrmColumn? column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic value2,
    bool lb = false,
    bool rb = false,
    List<OrmFilterCondition> filters = const [],
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
  OrmFilter._({this.filters = const []});

  factory OrmFilter.lb() {
    return OrmFilter._(
        filters: [
      const OrmFilterCondition(leftBracket: true, isBracketOnly: true)
    ].toList());
  }
  late final List<OrmFilterCondition> filters;

  OrmFilterCondition _addFilter(
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
    return OrmFilterCondition(
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

  OrmFilter lb() {
    return OrmFilter(null, filters: [
      ...filters,
      const OrmFilterCondition(leftBracket: true, isBracketOnly: true)
    ]);
  }

  OrmFilter rb() {
    return OrmFilter(null, filters: [
      ...filters,
      const OrmFilterCondition(rightBracket: true, isBracketOnly: true)
    ]);
  }

  OrmFilter and(OrmColumn column,
      {OrmCondition condition = OrmCondition.equalTo,
      dynamic value,
      bool lb = false,
      bool rb = false}) {
    return OrmFilter(null, filters: [
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

  OrmFilter filter(
    OrmColumn column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    bool lb = false,
    bool rb = false,
  }) {
    return OrmFilter(null, filters: [
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

  OrmFilter or(OrmColumn column,
      {OrmCondition condition = OrmCondition.equalTo,
      dynamic value,
      bool lb = false,
      bool rb = false}) {
    return OrmFilter(null, filters: [
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

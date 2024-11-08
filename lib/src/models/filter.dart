import 'package:equatable/equatable.dart';

import 'column_definition.dart';
import 'orm_condition.dart';
import 'filter_condition.dart';

class Filter extends Equatable {
  /// [openGroup] adds left bracket, [closeGroup] adds right bracket
  Filter(
    ColumnDefinition? column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic secondaryValue,
    bool openGroup = false,
    bool closeGroup = false,
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
          openGroup: openGroup,
          closeGroup: closeGroup,
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
        filters: [const FilterCondition(openGroup: true, isForGrouping: true)]
            .toList());
  }
  late final List<FilterCondition> filters;

  FilterCondition _addFilter(
    ColumnDefinition column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic secondaryValue,
    bool openGroup = false,
    bool closeGroup = false,
    bool isForGrouping = false,
    bool and = false,
    bool or = false,
  }) {
    return FilterCondition(
      column: column,
      condition: condition,
      value: value,
      secondaryValue: secondaryValue,
      openGroup: openGroup,
      closeGroup: closeGroup,
      isForGrouping: isForGrouping,
      and: and,
      or: or,
    );
  }

  Filter startGroup() {
    return Filter(null, filters: [
      ...filters,
      const FilterCondition(openGroup: true, isForGrouping: true)
    ]);
  }

  Filter endGroup() {
    return Filter(null, filters: [
      ...filters,
      const FilterCondition(closeGroup: true, isForGrouping: true)
    ]);
  }

  Filter and(ColumnDefinition column,
      {OrmCondition condition = OrmCondition.equalTo,
      dynamic value,
      dynamic secondaryValue,
      bool openGroup = false,
      bool closeGroup = false}) {
    return Filter(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        secondaryValue: secondaryValue,
        openGroup: openGroup,
        closeGroup: closeGroup,
        and: true,
      )
    ]);
  }

  Filter filter(
    ColumnDefinition column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic secondaryValue,
    bool openGroup = false,
    bool closeGroup = false,
  }) {
    return Filter(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        secondaryValue: secondaryValue,
        openGroup: openGroup,
        closeGroup: closeGroup,
      )
    ]);
  }

  Filter or(
    ColumnDefinition column, {
    OrmCondition condition = OrmCondition.equalTo,
    dynamic value,
    dynamic secondaryValue,
    bool openGroup = false,
    bool closeGroup = false,
  }) {
    return Filter(null, filters: [
      ...filters,
      _addFilter(
        column,
        condition: condition,
        value: value,
        secondaryValue: secondaryValue,
        openGroup: openGroup,
        closeGroup: closeGroup,
        or: true,
      )
    ]);
  }

  @override
  List<Object?> get props => [filters];
}

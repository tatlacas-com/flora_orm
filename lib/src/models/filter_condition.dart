import 'package:equatable/equatable.dart';

import 'column_definition.dart';
import 'orm_condition.dart';

class FilterCondition extends Equatable {
  const FilterCondition({
    this.column,
    this.condition = OrmCondition.equalTo,
    this.value,
    this.value2,
    this.leftBracket = false,
    this.rightBracket = false,
    this.isBracketOnly = false,
    this.and = false,
    this.or = false,
  });
  final ColumnDefinition? column;
  final OrmCondition condition;
  final dynamic value;
  final dynamic value2;
  final bool leftBracket;
  final bool rightBracket;
  final bool isBracketOnly;
  final bool and;
  final bool or;

  @override
  List<Object?> get props => [
        column,
        condition,
        value,
        value2,
        leftBracket,
        rightBracket,
        isBracketOnly,
        and,
        or,
      ];
}

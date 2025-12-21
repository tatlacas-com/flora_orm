import 'package:equatable/equatable.dart';

import 'package:flora_orm/src/model/column_definition.dart';
import 'package:flora_orm/src/model/model.dart';
import 'package:flora_orm/src/model/orm_condition.dart';

class FilterCondition<TModel extends ModelBase> extends Equatable {
  const FilterCondition({
    this.column,
    this.condition = OrmCondition.isEqualTo,
    this.value,
    this.secondaryValue,
    this.openGroup = false,
    this.closeGroup = false,
    this.isForGrouping = false,
    this.and = false,
    this.or = false,
  });
  final ColumnDefinition<TModel, dynamic>? column;
  final OrmCondition condition;
  final dynamic value;
  final dynamic secondaryValue;
  final bool openGroup;
  final bool closeGroup;
  final bool isForGrouping;
  final bool and;
  final bool or;

  @override
  List<Object?> get props => [
        column,
        condition,
        value,
        secondaryValue,
        openGroup,
        closeGroup,
        isForGrouping,
        and,
        or,
      ];
}

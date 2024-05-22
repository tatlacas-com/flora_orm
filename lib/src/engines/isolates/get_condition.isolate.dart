import 'package:tatlacas_orm/src/models/sql_condition.dart';

String getCondition(SqlCondition condition) {
  switch (condition) {
    case SqlCondition.equalTo:
      return ' = ? ';
    case SqlCondition.notEqualTo:
      return ' <> ? ';
    case SqlCondition.isNull:
      return ' IS NULL ';
    case SqlCondition.notNull:
      return ' IS NOT NULL ';
    case SqlCondition.lessThan:
      return ' < ? ';
    case SqlCondition.greaterThan:
      return ' > ? ';
    case SqlCondition.greaterThanOrEqual:
      return ' >= ? ';
    case SqlCondition.lessThanOrEqual:
      return ' <= ? ';
    case SqlCondition.between:
      return ' BETWEEN ? AND ? ';
    case SqlCondition.notBetween:
      return ' NOT BETWEEN ? AND ? ';
    case SqlCondition.isIn:
      return ' IN ';
    case SqlCondition.notIn:
      return ' NOT IN ';
    case SqlCondition.like:
      return ' LIKE ? ';
    case SqlCondition.notLike:
      return ' NOT LIKE ? ';
  }
}

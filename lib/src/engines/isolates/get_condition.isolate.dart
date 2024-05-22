import 'package:tatlacas_orm/src/models/orm_condition.dart';

String getCondition(OrmCondition condition) {
  switch (condition) {
    case OrmCondition.equalTo:
      return ' = ? ';
    case OrmCondition.notEqualTo:
      return ' <> ? ';
    case OrmCondition.isNull:
      return ' IS NULL ';
    case OrmCondition.notNull:
      return ' IS NOT NULL ';
    case OrmCondition.lessThan:
      return ' < ? ';
    case OrmCondition.greaterThan:
      return ' > ? ';
    case OrmCondition.greaterThanOrEqual:
      return ' >= ? ';
    case OrmCondition.lessThanOrEqual:
      return ' <= ? ';
    case OrmCondition.between:
      return ' BETWEEN ? AND ? ';
    case OrmCondition.notBetween:
      return ' NOT BETWEEN ? AND ? ';
    case OrmCondition.isIn:
      return ' IN ';
    case OrmCondition.notIn:
      return ' NOT IN ';
    case OrmCondition.like:
      return ' LIKE ? ';
    case OrmCondition.notLike:
      return ' NOT LIKE ? ';
  }
}

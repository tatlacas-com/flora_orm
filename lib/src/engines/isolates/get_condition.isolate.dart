import 'package:flora_orm/src/models/orm_condition.dart';

String getCondition(String columnName, OrmCondition condition) {
  switch (condition) {
    case OrmCondition.isEqualTo:
      return '$columnName = ? ';
    case OrmCondition.isNotEqualTo:
      return '$columnName <> ? ';
    case OrmCondition.isNull:
      return '$columnName IS NULL ';
    case OrmCondition.isNotNull:
      return '$columnName IS NOT NULL ';
    case OrmCondition.isNotEmpty:
      return "($columnName IS NOT NULL AND $columnName != '') ";
    case OrmCondition.isEmpty:
      return "($columnName IS NOT NULL AND $columnName = '') ";
    case OrmCondition.isNullOrEmpty:
      return "($columnName IS NULL OR $columnName = '') ";
    case OrmCondition.isLessThan:
      return '$columnName < ? ';
    case OrmCondition.isGreaterThan:
      return '$columnName > ? ';
    case OrmCondition.isGreaterThanOrEqual:
      return '$columnName >= ? ';
    case OrmCondition.isLessThanOrEqual:
      return '$columnName <= ? ';
    case OrmCondition.isBetween:
      return '$columnName BETWEEN ? AND ? ';
    case OrmCondition.isNotBetween:
      return '$columnName NOT BETWEEN ? AND ? ';
    case OrmCondition.isIn:
      return '$columnName IN ';
    case OrmCondition.isNotIn:
      return '$columnName NOT IN ';
    case OrmCondition.includes:
      return '$columnName LIKE ? ';
    case OrmCondition.excludes:
      return '$columnName NOT LIKE ? ';
  }
}

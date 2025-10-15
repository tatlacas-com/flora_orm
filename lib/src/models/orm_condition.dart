enum OrmCondition {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isGreaterThan,
  isLessThanOrEqual,
  isGreaterThanOrEqual,
  isBetween,
  isNull,
  isNotNull,
  isEmpty,
  isNullOrEmpty,
  isNotEmpty,
  isIn,
  includes,
  excludes,
  isNotIn,
  isNotBetween,
  ;

  static List<OrmCondition> get noArgsConditions =>
      [isNull, isNotNull, isEmpty, isNullOrEmpty, isNotEmpty];
}

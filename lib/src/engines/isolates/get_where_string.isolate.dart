import 'package:tatlacas_orm/src/engines/isolates/db_value.isolate.dart';
import 'package:tatlacas_orm/src/engines/isolates/get_condition.isolate.dart';
import 'package:tatlacas_orm/src/models/entity.dart';
import 'package:tatlacas_orm/src/models/formatted_query.dart';
import 'package:tatlacas_orm/src/models/sql_condition.dart';
import 'package:tatlacas_orm/src/models/sql_where.dart';

FormattedQuery getWhereString<TEntity extends IEntity>(Filter filter) {
  StringBuffer stringBuffer = StringBuffer();
  final whereArgs = <dynamic>[];
  for (var element in filter.filters) {
    if (element.isBracketOnly) {
      if (element.leftBracket) stringBuffer.write('(');
      if (element.rightBracket) stringBuffer.write(')');
      continue;
    }
    if (element.and) {
      stringBuffer.write(' AND ');
    } else if (element.or) {
      stringBuffer.write(' OR ');
    }
    if (element.leftBracket) stringBuffer.write('(');

    stringBuffer.write(element.column!.name);
    stringBuffer.write(getCondition(element.condition));
    if (element.condition != SqlCondition.isNull &&
        element.condition != SqlCondition.notNull) {
      if ((element.condition == SqlCondition.isIn ||
              element.condition == SqlCondition.notIn) &&
          element.value is List) {
        final args = element.value as List;
        final argsQ = args.map((e) => '?').toList();
        final q = argsQ.join(', ');
        stringBuffer.write('($q)');
        whereArgs.addAll(args);
      } else {
        whereArgs.add(dbValue(element.value));
      }
    }
    if (element.condition == SqlCondition.between ||
        element.condition == SqlCondition.notBetween) {
      whereArgs.add(element.value2);
    }
    if (element.rightBracket) stringBuffer.write(')');
  }
  return FormattedQuery(filter: stringBuffer.toString(), whereArgs: whereArgs);
}

import 'package:flora_orm/src/engines/isolates/db_value.isolate.dart';
import 'package:flora_orm/src/engines/isolates/get_condition.isolate.dart';
import 'package:flora_orm/src/models/entity.dart';
import 'package:flora_orm/src/models/formatted_query.dart';
import 'package:flora_orm/src/models/orm_condition.dart';
import 'package:flora_orm/src/models/filter.dart';

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
    if (element.condition != OrmCondition.isNull &&
        element.condition != OrmCondition.notNull) {
      if ((element.condition == OrmCondition.isIn ||
              element.condition == OrmCondition.notIn) &&
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
    if (element.condition == OrmCondition.between ||
        element.condition == OrmCondition.notBetween) {
      whereArgs.add(element.secondaryValue);
    }
    if (element.rightBracket) stringBuffer.write(')');
  }
  return FormattedQuery(filter: stringBuffer.toString(), whereArgs: whereArgs);
}

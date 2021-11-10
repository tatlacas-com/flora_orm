import 'entity.dart';
import 'sql_column.dart';

extension SqlColumnX<TEntity extends IEntity, TType> on SqlColumn<TEntity,TType>{
  void setValue(Map<String, dynamic> map, TType? value) {
    if (columnType == ColumnType.Boolean)
      map[name] = (value == true || value == 1) ? 1 : 0;
    else if (columnType == ColumnType.DateTime) {
      if (value is DateTime)
        map[name] = value.toIso8601String();
      else
        map[name] = value;
    } else
      map[name] = value;
  }
}
import 'entity.dart';
import 'sql_column.dart';

extension SqlColumnX<TEntity extends IEntity, TType>
    on SqlColumn<TEntity, TType> {
  void setValue(Map<String, dynamic> map, TType? value) {
    map[name] = switch (columnType) {
      ColumnType.Boolean => (value == true || value == 1) ? 1 : 0,
      ColumnType.DateTime => switch (value) {
          DateTime() => value.toIso8601String(),
          _ => value
        },
      _ => value
    };
  }
}

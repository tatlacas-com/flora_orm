import 'package:flora_orm/src/model/column_definition.dart';
import 'package:flora_orm/src/model/model.dart';

extension ColumnDefinitionExtension<TModel extends ModelBase, TType>
    on ColumnDefinition<TModel, TType> {
  void setValue(Map<String, dynamic> map, TType? value) {
    map[name] = switch (columnType) {
      ColumnType.boolean => (value == true || value == 1) ? 1 : 0,
      ColumnType.dateTime => switch (value) {
          DateTime() => value.toIso8601String(),
          _ => value,
        },
      _ => value,
    };
  }
}

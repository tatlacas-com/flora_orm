part of 'model.dart';

abstract class ModelMeta<TModel extends ModelBase> {
  const ModelMeta();
  String get tableName;

  Iterable<ColumnDefinition<TModel, dynamic>> get columns;
  ColumnDefinition<TModel, String> get id;
  ColumnDefinition<TModel, String> get restorationId;

  ColumnDefinition<TModel, DateTime> get createdAt;

  ColumnDefinition<TModel, DateTime> get updatedAt;
}

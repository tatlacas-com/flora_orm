part of 'entity.dart';

abstract class EntityMeta<TEntity extends EntityBase> {
  const EntityMeta();
  String get tableName;

  Iterable<ColumnDefinition<TEntity, dynamic>> get columns;
  ColumnDefinition<TEntity, String> get id;
  ColumnDefinition<TEntity, String> get collectionId;

  ColumnDefinition<TEntity, DateTime> get createdAt;

  ColumnDefinition<TEntity, DateTime> get updatedAt;
}

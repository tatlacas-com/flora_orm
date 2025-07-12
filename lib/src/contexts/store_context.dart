import 'package:flora_orm/src/models/entity.dart';

abstract class StoreContext<TEntity extends EntityBase> {
  const StoreContext({
    required this.dbName,
    required this.dbVersion,
    required this.tables,
  });
  final int dbVersion;
  final String dbName;
  final List<TEntity> tables;

  Future<String> getDbPath();

  Future<String> getDbFullName();

  Future<int> getVersion();

  Future<void> close();
}

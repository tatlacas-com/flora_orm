import 'package:flora_orm/src/models/entity.dart';

abstract class DbContext<TEntity extends IEntity> {
  const DbContext({
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

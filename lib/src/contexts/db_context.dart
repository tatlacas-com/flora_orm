import '../models/entity.dart';

abstract class DbContext<TEntity extends IEntity> {
  const DbContext({
    required this.dbName,
    required this.dbVersion,
    required this.tables,
  });
  final int dbVersion;
  final String dbName;
  final List<IEntity> tables;

  Future<String> getDbPath();

  Future<String> getDbFullName();

  Future close();
}

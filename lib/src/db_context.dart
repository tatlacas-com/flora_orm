import 'models/entity.dart';

abstract class DbContext<TEntity extends IEntity> {
  final int dbVersion;
  final String dbName;
  final List<TEntity> tables;

  const DbContext(
      {required this.dbName, required this.dbVersion, required this.tables,});

  Future<String> getDbPath();

  Future<String> getDbFullName();

  Future close();
}

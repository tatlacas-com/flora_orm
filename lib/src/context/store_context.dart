import 'package:flora_orm/src/model/model.dart';

abstract class StoreContext<TModel extends ModelBase> {
  const StoreContext({
    required this.dbName,
    required this.dbVersion,
    required this.tables,
  });
  final int dbVersion;
  final String dbName;
  final List<TModel> tables;

  Future<String> getDbPath();

  Future<String> getDbFullName();

  Future<int> getVersion();

  Future<void> close();
}

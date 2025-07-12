import 'package:flora_orm/flora_orm.dart';

class SharedPreferenceStoreContext<TEntity extends EntityBase>
    extends StoreContext<TEntity> {
  SharedPreferenceStoreContext({
    required super.dbName,
    required super.dbVersion,
    required super.tables,
  });

  SharedPreferenceStoreContext<TEntity> copyWith({
    String? dbName,
    int? dbVersion,
    List<TEntity>? tables,
  }) {
    return SharedPreferenceStoreContext<TEntity>(
      dbName: dbName ?? this.dbName,
      dbVersion: dbVersion ?? this.dbVersion,
      tables: tables ?? this.tables,
    );
  }

  @override
  Future<String> getDbPath() {
    throw UnimplementedError();
  }

  @override
  Future<String> getDbFullName() async {
    throw UnimplementedError();
  }

  @override
  Future<int> getVersion() async {
    return dbVersion;
  }

  @override
  Future<void> close() async {}
}

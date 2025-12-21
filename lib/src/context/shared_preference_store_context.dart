import 'package:flora_orm/flora_orm.dart';

class SharedPreferenceStoreContext<TModel extends ModelBase>
    extends StoreContext<TModel> {
  SharedPreferenceStoreContext({
    required super.dbName,
    required super.dbVersion,
    required super.tables,
  });

  SharedPreferenceStoreContext<TModel> copyWith({
    String? dbName,
    int? dbVersion,
    List<TModel>? tables,
  }) {
    return SharedPreferenceStoreContext<TModel>(
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

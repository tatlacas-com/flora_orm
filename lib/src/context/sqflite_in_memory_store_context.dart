import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/context/sqflite_store_context_base.dart';
import 'package:flora_orm/src/open_options.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqfliteInMemoryStoreContext<TModel extends ModelBase>
    extends SqfliteStoreContextBase<TModel> {
  SqfliteInMemoryStoreContext({
    required super.dbName,
    required super.dbVersion,
    required super.tables,
  });

  SqfliteInMemoryStoreContext<TModel> copyWith({
    String? dbName,
    int? dbVersion,
    List<TModel>? tables,
  }) {
    return SqfliteInMemoryStoreContext<TModel>(
      dbName: dbName ?? this.dbName,
      dbVersion: dbVersion ?? this.dbVersion,
      tables: tables ?? this.tables,
    );
  }

  @override
  Future<Database> open() async {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    final databaseFactory = databaseFactoryFfi;

    return databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: SqfliteOpenDatabaseOptions(
        onCreate: onDbCreate,
        onUpgrade: onDbUpgrade,
        onDowngrade: onDbDowngrade,
        version: dbVersion,
      ),
    );
  }

  @override
  Future<String> getDbFullName() {
    throw UnimplementedError();
  }

  @override
  Future<String> getDbPath() {
    throw UnimplementedError();
  }

  @override
  Future<int> getVersion() async {
    return (await database).getVersion();
  }
}

import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/contexts/sqflite_store_context_base.dart';
import 'package:flora_orm/src/open_options.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqfliteCommonStoreContext<TEntity extends EntityBase>
    extends SqfliteStoreContextBase<TEntity> {
  SqfliteCommonStoreContext({
    required super.dbName,
    required super.dbVersion,
    required super.tables,
  });

  SqfliteCommonStoreContext<TEntity> copyWith({
    String? dbName,
    int? dbVersion,
    List<TEntity>? tables,
  }) {
    return SqfliteCommonStoreContext<TEntity>(
      dbName: dbName ?? this.dbName,
      dbVersion: dbVersion ?? this.dbVersion,
      tables: tables ?? this.tables,
    );
  }

  @override
  Future<String> getDbPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  @override
  Future<String> getDbFullName() async {
    return join(await getDbPath(), dbName);
  }

  @override
  Future<Database> open() async {
    sqfliteFfiInit();

    final databaseFactory = databaseFactoryFfi;
    return databaseFactory.openDatabase(
      await getDbFullName(),
      options: SqfliteOpenDatabaseOptions(
        onCreate: onDbCreate,
        onUpgrade: onDbUpgrade,
        onDowngrade: onDbDowngrade,
        version: dbVersion,
      ),
    );
  }

  @override
  Future<int> getVersion() async {
    return (await database).getVersion();
  }
}

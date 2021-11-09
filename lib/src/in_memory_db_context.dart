import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tatlacas_sql_storage/tatlacas_sql_storage.dart';

import 'base_context.dart';
import 'open_options.dart';

class InMemoryDbContext extends BaseContext {

  InMemoryDbContext({
    required String dbName,
    required int dbVersion,
    required List<IEntity> tables,
  }) : super(
          dbName: dbName,
          dbVersion: dbVersion,
          tables: tables,
        );



  @override
  Future<Database> open() async {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    var databaseFactory = databaseFactoryFfi;

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


}

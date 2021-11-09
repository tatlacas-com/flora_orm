import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tatlacas_sql_storage/tatlacas_sql_storage.dart';
import 'base_context.dart';
import 'open_options.dart';

class SqfliteCommonDbContext extends BaseContext {

  SqfliteCommonDbContext({
    required String dbName,
    required int dbVersion,
    required List<IEntity> tables,
  }) : super(
          dbName: dbName,
          dbVersion: dbVersion,
          tables: tables,
        );


  Future<String> getDbPath() async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  Future<String> getDbFullName() async {
    return join(await getDbPath(), dbName);
  }

  @override
  Future<Database> open() async {
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
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
}

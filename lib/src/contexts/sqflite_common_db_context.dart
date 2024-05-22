import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../tatlacas_orm.dart';
import 'base_context.dart';
import '../open_options.dart';

class SqfliteCommonDbContext extends BaseContext {
  SqfliteCommonDbContext({
    required super.dbName,
    required super.dbVersion,
    required super.tables,
  });

  SqfliteCommonDbContext copyWith({
    String? dbName,
    int? dbVersion,
    List<IEntity>? tables,
  }) {
    return SqfliteCommonDbContext(
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

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../sql.dart';

import 'base_context.dart';
import 'open_options.dart';

class SqfliteInMemoryDbContext extends BaseContext {

  SqfliteInMemoryDbContext({
    required String dbName,
    required int dbVersion,
    required List<IEntity> tables,
  }) : super(
          dbName: dbName,
          dbVersion: dbVersion,
          tables: tables,
        );


  SqfliteInMemoryDbContext copyWith({
     String? dbName,
     int? dbVersion,
     List<IEntity>? tables,
  }) {
    return SqfliteInMemoryDbContext(
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

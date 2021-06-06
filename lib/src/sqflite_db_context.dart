import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tatlacas_sql_storage/tatlacas_sql_storage.dart';

abstract class SqfliteDbContext extends DbContext<Entity> {
  Database? _database;

  SqfliteDbContext({
    required String dbName,
    required int dbVersion,
    required List<Entity> tables,
  }) : super(
          dbName: dbName,
          dbVersion: dbVersion,
          tables: tables,
        );

  Future<Database> get database async {
    if (_database == null) _database = await _open();
    return _database!;
  }

  Future<String> getDbPath() async =>
      (await getApplicationDocumentsDirectory()).path;

  Future<Database> _open() async {
    return openDatabase(
      // Set the path to the database.
      join(await getDbPath(), dbName),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.transaction((txn) async {
          var batch = txn.batch();
          tables.forEach((element) {
            final query = element.createTable(version);
            batch.execute(query);
          });
          batch.commit(noResult: true);
        });
        await db.transaction((txn) async {
          var batch = txn.batch();
          tables.forEach((element) {
            final queries = element.onCreateComplete(version);
            if (queries.isNotEmpty == true) {
              queries.forEach((query) {
                batch.execute(query);
              });
            }
          });
          batch.commit(noResult: true);
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Run the CREATE TABLE statement on the database.
        await db.transaction((txn) async {
          var batch = txn.batch();
          tables.forEach((element) {
            final queries = element.upgradeTable(oldVersion, newVersion);
            if (queries.isNotEmpty == true) {
              queries.forEach((query) {
                batch.execute(query);
              });
            }
          });
          batch.commit(noResult: true);
        });
        await db.transaction((txn) async {
          var batch = txn.batch();
          tables.forEach((element) async {
            final queries = element.onUpgradeComplete(oldVersion, newVersion);
            if (queries.isNotEmpty == true) {
              queries.forEach((query) {
                batch.execute(query);
              });
            }
          });
          batch.commit(noResult: true);
        });
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        // Run the CREATE TABLE statement on the database.
        await db.transaction((txn) async {
          var batch = txn.batch();
          tables.forEach((element) {
            final queries = element.downgradeTable(oldVersion, newVersion);
            if (queries.isNotEmpty == true) {
              queries.forEach((query) {
                batch.execute(query);
              });
            }
          });
          batch.commit(noResult: true);
        });
        await db.transaction((txn) async {
          var batch = txn.batch();
          tables.forEach((element) async {
            final queries = element.onDowngradeComplete(oldVersion, newVersion);
            if (queries.isNotEmpty == true) {
              queries.forEach((query) {
                batch.execute(query);
              });
            }
          });
          batch.commit(noResult: true);
        });
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: dbVersion,
    );
  }

  Future close() async => _database?.close();
}

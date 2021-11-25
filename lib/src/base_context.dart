import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../sql.dart';


abstract class BaseContext extends DbContext<IEntity> {
  Database? _database;

  BaseContext({
    required String dbName,
    required int dbVersion,
    required List<IEntity> tables,
  }) : super(
    dbName: dbName,
    dbVersion: dbVersion,
    tables: tables,
  );

  Future<Database> get database async {
    if (_database == null) _database = await open();
    return _database!;
  }

  @protected
  Future<Database> open();

  @override
  Future close() async{
  await _database?.close();
  _database = null;
}


  @override
  Future<String> getDbFullName() {
    throw UnimplementedError();
  }

  @override
  Future<String> getDbPath() {
    throw UnimplementedError();
  }

  FutureOr<void> onDbDowngrade(db, oldVersion, newVersion) async {
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
  }

  FutureOr<void> onDbUpgrade(db, oldVersion, newVersion) async {
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
  }

  FutureOr<void> onDbCreate(db, version) async {
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
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
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
  Future<Database> open(){
    throw UnimplementedError('Not supported');
  }

  @override
  Future close() async {
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

  FutureOr<void> onDbDowngrade(
      Database db, int oldVersion, int newVersion) async {
    // Run the CREATE TABLE statement on the database.
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var element in tables) {
        final queries = element.downgradeTable(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          queries.forEach((query) {
            batch.execute(query);
          });
        }
      }
      var result = await batch.commit(noResult: true);
      if (kDebugMode)
        print('***Database downgraded from $oldVersion to $newVersion');
      _logBatchResult('onDbDowngrade', result);
    });
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var element in tables) {
        final queries = element.onDowngradeComplete(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          queries.forEach((query) {
            batch.execute(query);
          });
        }
      }
      var result = await batch.commit(noResult: true);
      _logBatchResult('After onDbDowngrade', result);
    });
  }

  FutureOr<void> onDbUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Run the CREATE TABLE statement on the database.
    await db.transaction((txn) async {
      var batch = txn.batch();
      var upgradeQueriesFound = false;
      for (var element in tables) {
        final queries = element.upgradeTable(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          upgradeQueriesFound = true;
          queries.forEach((query) {
            batch.execute(query);
          });
        }
      }
      if (!upgradeQueriesFound && kDebugMode) {
        throw ArgumentError(
            'No Upgrade queries found. If you added new entities, make sure they are are added in EntitiesDbConfig.tables');
      }
      var result = await batch.commit();
      if (kDebugMode) {
        print('***Database upgraded from $oldVersion to $newVersion');
        _logBatchResult('onDbUpgrade', result);
      }
    });
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var element in tables) {
        final queries = element.onUpgradeComplete(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          queries.forEach((query) {
            batch.execute(query);
          });
        } else {}
      }
      var result = await batch.commit();
      _logBatchResult('After onDbUpgrade', result);
    });
  }

  void _logBatchResult(String what, List<Object?> res) {
    if (!kDebugMode) return;
    if (res.isNotEmpty) {
      print('#################### $what ###############');
      res.forEach((element) {
        print(element);
      });
      print('#################### $what END ###############');
    }
  }

  FutureOr<void> onDbCreate(Database db, int version) async {
    // Run the CREATE TABLE statement on the database.
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var element in tables) {
        final query = element.createTable(version);
        batch.execute(query);
      }
      var result = await batch.commit();
      if (kDebugMode)
        print('***Database tables created with version from $version');
      _logBatchResult('onDbCreate', result);
    });
    await db.transaction((txn) async {
      var batch = txn.batch();
      for (var element in tables) {
        final queries = element.onCreateComplete(version);
        if (queries.isNotEmpty == true) {
          queries.forEach((query) {
            batch.execute(query);
          });
        }
      }
      var result = await batch.commit();
      _logBatchResult('After onDbCreate', result);
    });
  }
}

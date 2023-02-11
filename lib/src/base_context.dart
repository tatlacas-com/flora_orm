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
  Future<Database> open() {
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
      List<String> allQueries = [];
      for (var element in tables) {
        final queries = element.downgradeTable(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          queries.forEach((query) {
            batch.execute(query);
          });
        }
      }
      await batch.commit(noResult: true);
      _logBatchResult('onDbDowngrade', allQueries,
          'Database downgraded from $oldVersion to $newVersion');
    });
    await db.transaction((txn) async {
      var batch = txn.batch();
      List<String> allQueries = [];
      for (var element in tables) {
        final queries = element.onDowngradeComplete(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          queries.forEach((query) {
            batch.execute(query);
          });
        }
      }
      await batch.commit(noResult: true);
      _logBatchResult('After onDbDowngrade', allQueries, null);
    });
  }

  FutureOr<void> onDbUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Run the CREATE TABLE statement on the database.
    await db.transaction((txn) async {
      var batch = txn.batch();
      var upgradeQueriesFound = false;
      List<String> allQueries = [];
      for (var element in tables) {
        final queries = element.upgradeTable(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
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
      await batch.commit(noResult: true);
      _logBatchResult('onDbUpgrade', allQueries,
          'Database upgraded from $oldVersion to $newVersion');
    });
    await db.transaction((txn) async {
      var batch = txn.batch();
      List<String> allQueries = [];
      for (var element in tables) {
        final queries = element.onUpgradeComplete(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          queries.forEach((query) {
            batch.execute(query);
          });
        } else {}
      }
      await batch.commit(noResult: true);
      _logBatchResult('After onDbUpgrade', allQueries, null);
    });
  }

  void _logBatchResult(String what, List<Object?> res, String? moreInfo) {
    if (res.isNotEmpty) {
      debugPrint('╔${'═' * 4} SQFLITE $what╗');
      if (moreInfo != null) {
        _printMaxed(moreInfo);
      }
      for (final element in res) {
        if (element != null) {
          _printMaxed(element.toString(), prefix: 'Query:');
        }
      }
      debugPrint('╚${'═' * 80}╝');
    }
  }

  void _printMaxed(String str, {String? prefix}) {
    if (str.length <= 78) {
      if (str.contains('\n')) {
        final ls = str.split('\n');
        for (final s in ls) {
          _printMaxed(s, prefix: prefix);
          prefix = null;
        }
      } else {
        debugPrint('╟ ${prefix ?? ''} $str');
      }
    } else {
      _printMaxed(str.substring(0, 78), prefix: prefix);
      _printMaxed(str.substring(78));
    }
  }

  FutureOr<void> onDbCreate(Database db, int version) async {
    // Run the CREATE TABLE statement on the database.
    await db.transaction((txn) async {
      var batch = txn.batch();
      List<String> allQueries = [];
      for (var element in tables) {
        final query = element.createTable(version);
        allQueries.add(query);
        batch.execute(query);
      }
      await batch.commit(noResult: true);

      _logBatchResult('onDbCreate', allQueries,
          'Database tables created with version from $version');
    });
    await db.transaction((txn) async {
      var batch = txn.batch();
      List<String> allQueries = [];
      for (var element in tables) {
        final queries = element.onCreateComplete(version);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          queries.forEach((query) {
            batch.execute(query);
          });
        }
      }
      await batch.commit(noResult: true);
      _logBatchResult('After onDbCreate', allQueries, null);
    });
  }
}

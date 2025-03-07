import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../../flora_orm.dart';

abstract class BaseContext<TEntity extends IEntity> extends DbContext<TEntity> {
  BaseContext({
    required super.dbName,
    required super.dbVersion,
    required super.tables,
  });
  Database? _database;

  Future<Database> get database async {
    _database ??= await open();
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
          for (var query in queries) {
            batch.execute(query);
          }
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
          for (var query in queries) {
            batch.execute(query);
          }
        }
      }
      await batch.commit(noResult: true);
      _logBatchResult('After onDbDowngrade', allQueries, null);
    });
  }

  List<String> _upgradeQueries(
      IEntity element, int oldVersion, int newVersion) {
    List<String> allQueries = [];
    List<ColumnDefinition> columns = [];
    while (++oldVersion < newVersion) {
      columns.addAll(element.addColumnsAt(oldVersion));
    }
    columns.addAll(element.addColumnsAt(newVersion));
    allQueries.addAll(columns.map(
      (column) => element.addColumn(column),
    ));
    allQueries.addAll(element.additionalUpgradeQueries(oldVersion, newVersion));
    return allQueries;
  }

  bool _recreateOn(IEntity element, int oldVersion, int newVersion) {
    while (++oldVersion < newVersion) {
      if (element.recreateTableAt(oldVersion)) {
        return true;
      }
    }
    return element.recreateTableAt(newVersion);
  }

  bool _createOn(IEntity element, int oldVersion, int newVersion) {
    while (++oldVersion < newVersion) {
      if (element.createTableAt(oldVersion)) {
        return true;
      }
    }
    return element.createTableAt(newVersion);
  }

  FutureOr<void> onDbUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Run the CREATE TABLE statement on the database.
    await db.transaction((txn) async {
      var batch = txn.batch();
      var upgradeQueriesFound = false;
      List<String> allQueries = [];
      for (var element in tables) {
        final queries = _recreateOn(element, oldVersion, newVersion)
            ? element.recreateTable(newVersion)
            : _createOn(element, oldVersion, newVersion)
                ? [element.createTable(newVersion)]
                : _upgradeQueries(element, oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          upgradeQueriesFound = true;
          for (var query in queries) {
            batch.execute(query);
          }
        }
      }
      if (!upgradeQueriesFound && kDebugMode) {
        throw ArgumentError(
            'No Upgrade queries found. If you added new entities, make sure they are also added to OrmManager.tables');
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
          for (var query in queries) {
            batch.execute(query);
          }
        } else {}
      }
      await batch.commit(noResult: true);
      _logBatchResult('After onDbUpgrade', allQueries, null);
    });
  }

  void _logBatchResult(String what, List<Object?> res, String? moreInfo) {
    if (res.isNotEmpty) {
      final title = 'SQFLITE $what';
      final titleSize = title.length + 5;
      debugPrint(
          '╔${'═' * 4} SQFLITE $what ${'═' * (titleSize < 78 ? (78 - titleSize) : 0)}╗');
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
          for (var query in queries) {
            batch.execute(query);
          }
        }
      }
      await batch.commit(noResult: true);
      _logBatchResult('After onDbCreate', allQueries, null);
    });
  }
}

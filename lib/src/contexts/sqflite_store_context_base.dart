import 'dart:async';

import 'package:flora_orm/flora_orm.dart';
import 'package:sqflite_common/sqlite_api.dart';

abstract class SqfliteStoreContextBase<TEntity extends EntityBase>
    extends StoreContext<TEntity> {
  SqfliteStoreContextBase({
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
  Future<void> close() async {
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
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Run the CREATE TABLE statement on the database.
    await db.transaction((txn) async {
      final batch = txn.batch();
      final allQueries = <String>[];
      for (final element in tables) {
        final queries = element.downgradeTable(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          for (final query in queries) {
            batch.execute(query);
          }
        }
      }
      await batch.commit(noResult: true);
      _logBatchResult(
        'onDbDowngrade',
        allQueries,
        'Database downgraded from $oldVersion to $newVersion',
      );
    });
    await db.transaction((txn) async {
      final batch = txn.batch();
      final allQueries = <String>[];
      for (final element in tables) {
        final queries = element.onDowngradeComplete(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          for (final query in queries) {
            batch.execute(query);
          }
        }
      }
      await batch.commit(noResult: true);
      _logBatchResult('After onDbDowngrade', allQueries, null);
    });
  }

  List<String> _upgradeQueries(
    TEntity element,
    int oldVersion,
    int newVersion,
  ) {
    if (element is! Entity) {
      return [];
    }
    final allQueries = <String>[];
    final columns = <ColumnDefinition<TEntity, dynamic>>[];
    var old = oldVersion;
    while (++old < newVersion) {
      columns.addAll(element.addColumnsAt(old).cast());
    }
    columns.addAll(element.addColumnsAt(newVersion).cast());
    allQueries
      ..addAll(
        columns.map(
          (column) => element.addColumn(column),
        ),
      )
      ..addAll(element.additionalUpgradeQueries(old, newVersion));
    return allQueries;
  }

  bool _recreateOn(EntityBase element, int oldVersion, int newVersion) {
    var old = oldVersion;
    while (++old < newVersion) {
      if (element.recreateTableAt(old)) {
        return true;
      }
    }
    return element.recreateTableAt(newVersion);
  }

  bool _createOn(EntityBase element, int oldVersion, int newVersion) {
    var old = oldVersion;
    while (++old < newVersion) {
      if (element.createTableAt(old)) {
        return true;
      }
    }
    return element.createTableAt(newVersion);
  }

  FutureOr<void> onDbUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Run the CREATE TABLE statement on the database.
    await db.transaction((txn) async {
      final batch = txn.batch();
      var upgradeQueriesFound = false;
      final allQueries = <String>[];
      for (final element in tables) {
        final queries = _recreateOn(element, oldVersion, newVersion)
            ? element.recreateTable(newVersion)
            : _createOn(element, oldVersion, newVersion)
                ? [element.createTable(newVersion)]
                : _upgradeQueries(element, oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          upgradeQueriesFound = true;
          for (final query in queries) {
            batch.execute(query);
          }
        }
      }
      if (!upgradeQueriesFound && kDebugMode) {
        throw ArgumentError(
          'No Upgrade queries found. If you added new entities, '
          'make sure they are also added to OrmContext.tables',
        );
      }
      await batch.commit(noResult: true);
      _logBatchResult(
        'onDbUpgrade',
        allQueries,
        'Database upgraded from $oldVersion to $newVersion',
      );
    });
    await db.transaction((txn) async {
      final batch = txn.batch();
      final allQueries = <String>[];
      for (final element in tables) {
        final queries = element.onUpgradeComplete(oldVersion, newVersion);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          for (final query in queries) {
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
      final paddingsCount = (titleSize < 78 ? (78 - titleSize) : 0);
      debugPrint(
        '╔${'═' * 4} SQFLITE $what ${'═' * paddingsCount}╗',
      );
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
      final batch = txn.batch();
      final allQueries = <String>[];
      for (final element in tables) {
        final query = element.createTable(version);
        allQueries.add(query);
        batch.execute(query);
      }
      await batch.commit(noResult: true);

      _logBatchResult(
        'onDbCreate',
        allQueries,
        'Database tables created with version from $version',
      );
    });
    await db.transaction((txn) async {
      final batch = txn.batch();
      final allQueries = <String>[];
      for (final element in tables) {
        final queries = element.onCreateComplete(version);
        if (queries.isNotEmpty == true) {
          allQueries.addAll(queries);
          for (final query in queries) {
            batch.execute(query);
          }
        }
      }
      await batch.commit(noResult: true);
      _logBatchResult('After onDbCreate', allQueries, null);
    });
  }
}

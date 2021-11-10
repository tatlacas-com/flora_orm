import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../sql.dart';

import 'base_context.dart';

class SqfliteDbContext extends BaseContext {

  SqfliteDbContext({
    required String dbName,
    required int dbVersion,
    required List<IEntity> tables,
  }) : super(
          dbName: dbName,
          dbVersion: dbVersion,
          tables: tables,
        );



  Future<String> getDbPath() async =>
      (await getApplicationDocumentsDirectory()).path;

  Future<String> getDbFullName() async => join(await getDbPath(), dbName);

  @protected
  Future<Database> open() async {
    return openDatabase(
      // Set the path to the database.
      await getDbFullName(),
      // When the database is first created, create a table to store dogs.
      onCreate: onDbCreate,
      onUpgrade: onDbUpgrade,
      onDowngrade: onDbDowngrade,
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: dbVersion,
    );
  }

}

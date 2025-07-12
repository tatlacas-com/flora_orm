import 'dart:async';

import 'package:flora_orm/src/contexts/sqflite_store_context_base.dart';
import 'package:flora_orm/src/models/entity.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteStoreContext<TEntity extends EntityBase>
    extends SqfliteStoreContextBase<TEntity> {
  SqfliteStoreContext({
    required super.dbName,
    required super.dbVersion,
    required super.tables,
  });

  @override
  Future<String> getDbPath() async =>
      (await getApplicationDocumentsDirectory()).path;

  @override
  Future<String> getDbFullName() async => join(await getDbPath(), dbName);

  @override
  @protected
  Future<Database> open() async {
    return openDatabase(
      await getDbFullName(),
      onCreate: onDbCreate,
      onUpgrade: onDbUpgrade,
      onDowngrade: onDbDowngrade,
      version: dbVersion,
    );
  }

  @override
  Future<int> getVersion() async {
    return (await database).getVersion();
  }
}

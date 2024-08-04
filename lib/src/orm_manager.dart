import 'dart:io';

import 'package:flora_orm/engines/shared_preference_engine.dart';
import 'package:flora_orm/engines/sqflite_common_engine.dart';
import 'package:flora_orm/engines/sqflite_in_memory_engine.dart';
import 'package:flora_orm/engines/sqflite_storage.dart';
import 'package:flora_orm/flora_orm.dart';

class OrmManager {
  OrmManager({
    DbInUse dbInUse = DbInUse.sqflite,
    required bool isWeb,
    required int dbVersion,
    required String dbName,
    required List<IEntity> tables,
  }) : _dbInUse = dbInUse {
    if (_dbInUse == DbInUse.inMemory) {
      dbContext = SqfliteInMemoryDbContext(
        dbVersion: dbVersion,
        dbName: dbName,
        tables: tables,
      );
    } else if (_dbInUse == DbInUse.sqfliteCommon || Platform.isWindows) {
      dbContext = SqfliteCommonDbContext(
        dbVersion: dbVersion,
        dbName: dbName,
        tables: tables,
      );
    } else if (isWeb) {
      dbContext = SharedPreferenceContext(
        dbName: dbName,
        dbVersion: dbVersion,
        tables: tables,
      );
    } else {
      dbContext = SqfliteDbContext(
        dbVersion: dbVersion,
        dbName: dbName,
        tables: tables,
      );
    }
  }
  final DbInUse _dbInUse;
  late final DbContext dbContext;

  OrmEngine<TEntity, TMeta, DbContext<TEntity>>
      getStorage<TEntity extends IEntity, TMeta extends EntityMeta<TEntity>>(
          TEntity t) {
    if (dbContext is SharedPreferenceContext) {
      return SharedPreferenceEngine<TEntity, TMeta>(t, dbContext: dbContext);
    } else if (dbContext is SqfliteInMemoryDbContext) {
      return SqfliteInMemoryEngine<TEntity, TMeta>(t, dbContext: dbContext);
    } else if (dbContext is SqfliteCommonDbContext) {
      return SqfliteCommonEngine<TEntity, TMeta>(t, dbContext: dbContext);
    } else {
      return SqfliteEngine<TEntity, TMeta>(
        t,
        dbContext: dbContext,
      );
    }
  }
}

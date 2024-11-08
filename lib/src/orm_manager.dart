import 'dart:io';

import 'package:flora_orm/engines/shared_preference_engine.dart';
import 'package:flora_orm/engines/sqflite_common_engine.dart';
import 'package:flora_orm/engines/sqflite_in_memory_engine.dart';
import 'package:flora_orm/engines/sqflite_storage.dart';
import 'package:flora_orm/flora_orm.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OrmManager {
  OrmManager({
    DbEngine dbInUse = DbEngine.sqflite,
    required int dbVersion,
    required String dbName,
    required List<IEntity> tables,
  }) {
    if (kIsWeb && !dbInUse.suppportsWeb) {
      dbInUse = DbEngine.sharedPreferences;
    } else if (Platform.isWindows && !dbInUse.suppportsWindows) {
      dbInUse = DbEngine.sqfliteCommon;
    } else if (Platform.isLinux && !dbInUse.suppportsLinux) {
      dbInUse = DbEngine.sqfliteCommon;
    } else if (Platform.isMacOS && !dbInUse.suppportsLinux) {
      dbInUse = DbEngine.sqfliteCommon;
    }
    dbContext = switch (dbInUse) {
      DbEngine.inMemory => SqfliteInMemoryDbContext(
          dbVersion: dbVersion,
          dbName: dbName,
          tables: tables,
        ),
      DbEngine.sqfliteCommon => SqfliteCommonDbContext(
          dbVersion: dbVersion,
          dbName: dbName,
          tables: tables,
        ),
      DbEngine.sqflite => SqfliteDbContext(
          dbVersion: dbVersion,
          dbName: dbName,
          tables: tables,
        ),
      DbEngine.sharedPreferences => SharedPreferenceContext(
          dbName: dbName,
          dbVersion: dbVersion,
          tables: tables,
        ),
    };
  }
  late final DbContext dbContext;

  OrmEngine<TEntity, TMeta, DbContext<TEntity>>
      getStorage<TEntity extends IEntity, TMeta extends EntityMeta<TEntity>>(
          TEntity t) {
    return switch (dbContext) {
      SharedPreferenceContext() =>
        SharedPreferenceEngine<TEntity, TMeta>(t, dbContext: dbContext),
      SqfliteInMemoryDbContext() =>
        SqfliteInMemoryEngine<TEntity, TMeta>(t, dbContext: dbContext),
      SqfliteCommonDbContext() =>
        SqfliteCommonEngine<TEntity, TMeta>(t, dbContext: dbContext),
      _ => SqfliteEngine<TEntity, TMeta>(
          t,
          dbContext: dbContext,
        )
    } as OrmEngine<TEntity, TMeta, DbContext<TEntity>>;
  }
}

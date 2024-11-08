import 'dart:io';

import 'package:flora_orm/engines/shared_preference_engine.dart';
import 'package:flora_orm/engines/sqflite_common_engine.dart';
import 'package:flora_orm/engines/sqflite_in_memory_engine.dart';
import 'package:flora_orm/engines/sqflite_storage.dart';
import 'package:flora_orm/flora_orm.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OrmManager {
  OrmManager({
    DbInUse dbInUse = DbInUse.sqflite,
    required int dbVersion,
    required String dbName,
    required List<IEntity> tables,
  }) {
    if (kIsWeb && !dbInUse.suppportsWeb) {
      dbInUse = DbInUse.sharedPreferences;
    } else if (Platform.isWindows && !dbInUse.suppportsWindows) {
      dbInUse = DbInUse.sqfliteCommon;
    } else if (Platform.isLinux && !dbInUse.suppportsLinux) {
      dbInUse = DbInUse.sqfliteCommon;
    } else if (Platform.isMacOS && !dbInUse.suppportsLinux) {
      dbInUse = DbInUse.sqfliteCommon;
    }
    dbContext = switch (dbInUse) {
      DbInUse.inMemory => SqfliteInMemoryDbContext(
          dbVersion: dbVersion,
          dbName: dbName,
          tables: tables,
        ),
      DbInUse.sqfliteCommon => SqfliteCommonDbContext(
          dbVersion: dbVersion,
          dbName: dbName,
          tables: tables,
        ),
      DbInUse.sqflite => SqfliteDbContext(
          dbVersion: dbVersion,
          dbName: dbName,
          tables: tables,
        ),
      DbInUse.sharedPreferences => SharedPreferenceContext(
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

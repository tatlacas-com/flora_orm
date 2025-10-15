// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flora_orm/engines/shared_preference_engine.dart';
import 'package:flora_orm/engines/sqflite_common_engine.dart';
import 'package:flora_orm/engines/sqflite_in_memory_engine.dart';
import 'package:flora_orm/engines/sqflite_storage.dart';
import 'package:flora_orm/flora_orm.dart';

@Deprecated('Use OrmContext instead')
typedef OrmManager = OrmContext;

class OrmContext extends Equatable {
  OrmContext({
    required int dbVersion,
    required String dbName,
    required List<EntityBase> tables,
    DbEngine engine = DbEngine.sqflite,
  }) : assert(dbName.trim().isNotEmpty, 'dbName should not be empty') {
    if (kIsWeb && !engine.suppportsWeb) {
      engine = DbEngine.sharedPreferences;
    } else if (Platform.isWindows && !engine.suppportsWindows) {
      engine = DbEngine.sqfliteCommon;
    } else if (Platform.isLinux && !engine.suppportsLinux) {
      engine = DbEngine.sqfliteCommon;
    } else if (Platform.isMacOS && !engine.suppportsLinux) {
      engine = DbEngine.sqfliteCommon;
    }
    _engine = engine;
    final databaseName = dbName.trim();
    dbContext = switch (_engine) {
      DbEngine.inMemory => SqfliteInMemoryStoreContext(
          dbVersion: dbVersion,
          dbName: databaseName,
          tables: tables,
        ),
      DbEngine.sqfliteCommon => SqfliteCommonStoreContext(
          dbVersion: dbVersion,
          dbName: databaseName,
          tables: tables,
        ),
      DbEngine.sqflite => SqfliteStoreContext(
          dbVersion: dbVersion,
          dbName: databaseName,
          tables: tables,
        ),
      DbEngine.sharedPreferences => SharedPreferenceStoreContext(
          dbName: databaseName,
          dbVersion: dbVersion,
          tables: tables,
        ),
    };
  }
  late final StoreContext dbContext;

  late final DbEngine _engine;
  DbEngine get engine => _engine;

  OrmEngine<TEntity, TMeta, StoreContext<TEntity>>
      getStore<TEntity extends EntityBase, TMeta extends EntityMeta<TEntity>>(
    TEntity t,
  ) {
    return switch (dbContext) {
      SharedPreferenceStoreContext() =>
        SharedPreferenceEngine<TEntity, TMeta>(t, dbContext: dbContext),
      SqfliteInMemoryStoreContext() =>
        SqfliteInMemoryEngine<TEntity, TMeta>(t, dbContext: dbContext),
      SqfliteCommonStoreContext() =>
        SqfliteCommonEngine<TEntity, TMeta>(t, dbContext: dbContext),
      _ => SqfliteEngine<TEntity, TMeta>(
          t,
          dbContext: dbContext,
        )
    } as OrmEngine<TEntity, TMeta, StoreContext<TEntity>>;
  }

  @override
  List<Object?> get props => [
        _engine,
      ];

  OrmContext copyWith({
    DbEngine? engine,
    int? dbVersion,
    String? dbName,
    List<EntityBase>? tables,
  }) {
    return OrmContext(
      engine: engine ?? _engine,
      dbName: dbName ?? dbContext.dbName,
      dbVersion: dbVersion ?? dbContext.dbVersion,
      tables: tables ?? dbContext.tables,
    );
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flora_orm/engines/shared_preference_engine.dart';
import 'package:flora_orm/engines/sqflite_common_engine.dart';
import 'package:flora_orm/engines/sqflite_in_memory_engine.dart';
import 'package:flora_orm/engines/sqflite_storage.dart';
import 'package:flora_orm/flora_orm.dart';

class OrmManager extends Equatable {
  OrmManager({
    DbEngine engine = DbEngine.sqflite,
    required int dbVersion,
    required String dbName,
    required List<IEntity> tables,
  }) : _engine = engine {
    if (kIsWeb && !engine.suppportsWeb) {
      engine = DbEngine.sharedPreferences;
    } else if (Platform.isWindows && !engine.suppportsWindows) {
      engine = DbEngine.sqfliteCommon;
    } else if (Platform.isLinux && !engine.suppportsLinux) {
      engine = DbEngine.sqfliteCommon;
    } else if (Platform.isMacOS && !engine.suppportsLinux) {
      engine = DbEngine.sqfliteCommon;
    }
    dbContext = switch (engine) {
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
  final DbEngine _engine;

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

  @override
  List<Object?> get props => [];

  OrmManager copyWith({
    DbEngine? engine,
    int? dbVersion,
    String? dbName,
    List<IEntity>? tables,
  }) {
    return OrmManager(
      engine: engine ?? _engine,
      dbName: dbName ?? dbContext.dbName,
      dbVersion: dbVersion ?? dbContext.dbVersion,
      tables: tables ?? dbContext.tables,
    );
  }
}

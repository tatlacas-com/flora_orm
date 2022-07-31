import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatlacas_sqflite_storage/sql.dart';
import 'package:tatlacas_sqflite_storage/src/base_context.dart';


class SharedPreferenceContext extends BaseContext {
  SharedPreferenceContext({
    required String dbName,
    required int dbVersion,
    required List<IEntity> tables,
  }) : super(
    dbName: dbName,
    dbVersion: dbVersion,
    tables: tables,
  );

  SharedPreferenceContext copyWith({
    String? dbName,
    int? dbVersion,
    List<IEntity>? tables,
  }) {
    return SharedPreferenceContext(
      dbName: dbName ?? this.dbName,
      dbVersion: dbVersion ?? this.dbVersion,
      tables: tables ?? this.tables,
    );
  }

  Future<String> getDbPath() async {
    return '';
  }

  Future<String> getDbFullName() async {
    return dbName;
  }

}

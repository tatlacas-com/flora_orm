import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatlacas_sqflite_storage/sql.dart';
import 'package:tatlacas_sqflite_storage/src/base_storage.dart';
import 'package:tatlacas_sqflite_storage/src/shared_preference/shared_preference_context.dart';
import 'package:uuid/uuid.dart';

class SharedPreferenceStorage<TEntity extends IEntity>
    extends BaseStorage<TEntity, SharedPreferenceContext> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  SharedPreferenceStorage({required SharedPreferenceContext dbContext})
      : super(dbContext: dbContext);

  Future<String?> _read({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(key);
  }

  Future<void> _write(
      {required String key,
      required String? value,
      Map<String, dynamic>? additionalData}) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(key, value ?? '');
  }

  Future<String?> _delete({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(key);
  }

  @override
  Future<TEntity?> insert(TEntity item) async {
    if (item.id == null) item = item.setBaseParams(id: Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final json = jsonEncode(item.toJson());
    await _write(key: item.id!, value: json);
    return item;
  }

  Future<Map<String, dynamic>?> getEntity(
      TEntity type, {
        Iterable<SqlColumn>? columns,
        List<SqlOrder>? orderBy,
        required SqlWhere where,
        int? offset,
      }) async {

  }

  @override
  Future<List<TEntity>?> insertList(Iterable<TEntity> items) async {
    return [];
  }

  @override
  Future<TEntity?> insertOrUpdate(TEntity item) async {
    if (item.id == null) item = item.setBaseParams(id: Uuid().v4()) as TEntity;
    item = item.updateDates() as TEntity;
    final json = jsonEncode(item.toJson());
    await _write(key: item.id!, value: json);
    return item;
  }

  @override
  Future<List<TEntity>?> insertOrUpdateList(Iterable<TEntity> items) async {
    return [];
  }

  @override
  Future<int> delete(
    TEntity type, {
    required SqlWhere where,
  }) async {
    var item =
        where.filters.where((element) => element.column?.name == 'id').toList();
    if (item.isNotEmpty == true) {
      // await _delete(key: item[0].value); todo
      return 1;
    }
    return 0;
  }

  @override
  Future<int> update(
    TEntity item, {
    required SqlWhere where,
    Map<SqlColumn, dynamic>? columnValues,
  }) async {
    var query =
        where.filters.where((element) => element.column?.name == 'id').toList();
    if (query.isNotEmpty == true) {
      final json = jsonEncode(item.toJson());
      await _write(key: query[0].value, value: json);
      return 1;
    }
    return 0;
  }

  @override
  Future<List<Map<String, dynamic>>> query({
    SqlWhere? where,
    required TEntity type,
    Iterable<SqlColumn>? columns,
    List<SqlOrder>? orderBy,
    int? limit,
    int? offset,
  }) async {
    return [];
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    SqlWhere? where,
    String query,
  ) async {
    return [];
  }
}

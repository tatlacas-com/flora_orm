import 'package:flora_orm/flora_orm.dart';
import 'package:flora_orm/src/contexts/base_context.dart';

class SharedPreferenceContext<TEntity extends IEntity>
    extends BaseContext<TEntity> {
  SharedPreferenceContext({
    required super.dbName,
    required super.dbVersion,
    required super.tables,
  });

  SharedPreferenceContext<TEntity> copyWith({
    String? dbName,
    int? dbVersion,
    List<IEntity>? tables,
  }) {
    return SharedPreferenceContext<TEntity>(
      dbName: dbName ?? this.dbName,
      dbVersion: dbVersion ?? this.dbVersion,
      tables: tables ?? this.tables,
    );
  }

  @override
  Future<String> getDbPath() async {
    return '';
  }

  @override
  Future<String> getDbFullName() async {
    return dbName;
  }
}

import 'package:sqflite_common/sqlite_api.dart';

class SqfliteOpenDatabaseOptions implements OpenDatabaseOptions {
  SqfliteOpenDatabaseOptions({
    this.version,
    this.onConfigure,
    this.onCreate,
    this.onUpgrade,
    this.onDowngrade,
    this.onOpen,
    this.readOnly = false,
    this.singleInstance = true,
  });

  @override
  int? version;
  @override
  OnDatabaseConfigureFn? onConfigure;
  @override
  OnDatabaseCreateFn? onCreate;
  @override
  OnDatabaseVersionChangeFn? onUpgrade;
  @override
  OnDatabaseVersionChangeFn? onDowngrade;
  @override
  OnDatabaseOpenFn? onOpen;
  @override
  bool readOnly;
  @override
  bool singleInstance;

  @override
  String toString() {
    final map = <String, Object?>{};
    if (version != null) {
      map['version'] = version;
    }
    map['readOnly'] = readOnly;
    map['singleInstance'] = singleInstance;
    return map.toString();
  }
}

const column = OrmColumn<dynamic>();
const entity = OrmEntity();

/// Supported types:
///                 [String], [int], [double], [bool] and [double].
/// All other types will be stored as json, and can be encoded/decoded using the read/write functions associated with the column
class OrmColumn<TColumnType> {
  const OrmColumn({
    this.name,
    this.alias,
    this.writeFn,
    this.readFn,
    this.primaryKey = false,
    this.unique = false,
    this.autoIncrementPrimary = false,
    this.notNull,
    this.defaultValue,
  });
  final String? name;
  final String? alias;
  // write function name. defaults to toMap
  final String? writeFn;
  // read function name. defaults to fromMap
  final String? readFn;
  final bool primaryKey;
  final bool autoIncrementPrimary;
  final bool? notNull;
  final bool unique;
  final dynamic defaultValue;
}

class OrmEntity {
  const OrmEntity({
    this.tableName,
  });
  final String? tableName;
}

class NullableProp {
  const NullableProp();
}

class CopyableProp {
  const CopyableProp();
}

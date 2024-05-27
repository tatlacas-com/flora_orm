const column = OrmColumn();
const entity = OrmEntity();

/// Supported types:
///                 [String], [int], [double], [bool] and [double].
/// All other types will be stored as json, and can be encoded/decoded using the read/write functions associated with the column
class OrmColumn<TColumnType> {
  const OrmColumn({
    this.name,
    this.alias,
    this.writeFn,
    this.encodedJson = false,
    this.primaryKey = false,
    this.unique = false,
    this.autoIncrementPrimary = false,
    this.hasRead = false,
    this.isEnum = false,
    this.hasWrite = false,
    this.notNull,
    this.defaultValue,
  });
  final String? name;
  final String? alias;
  // write function name. defaults to toMap
  final String? writeFn;
  final bool encodedJson;
  final bool primaryKey;
  final bool isEnum;
  final bool autoIncrementPrimary;
  final bool hasRead;
  final bool hasWrite;
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

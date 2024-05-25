const column = OrmColumn();
const entity = OrmEntity();

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

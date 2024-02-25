// ignore_for_file: public_member_api_docs, sort_constructors_first

class DbColumn<TColumnType> {
  const DbColumn({
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

class DbEntity {
  const DbEntity({
    this.tableName,
    this.hasSuperColumns = false,
  });
  final String? tableName;
  final bool hasSuperColumns;
}

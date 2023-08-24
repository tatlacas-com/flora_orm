// ignore_for_file: public_member_api_docs, sort_constructors_first

class DbColumn<TColumnType> {
  const DbColumn({
    this.name,
    this.alias,
    this.encodedJson = false,
    this.primaryKey = false,
    this.unique = false,
    this.autoIncrementPrimary = false,
    this.hasReadFromDb = false,
    this.hasSaveToDb = false,
    this.notNull = false,
    this.nullable = false,
    this.defaultValue,
  });
  final String? name;
  final String? alias;
  final bool encodedJson;
  final bool primaryKey;
  final bool autoIncrementPrimary;
  final bool hasReadFromDb;
  final bool nullable;
  final bool hasSaveToDb;
  final bool notNull;
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

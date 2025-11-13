part of 'test.entity.dart';

mixin TestEntityMigrations on Entity<TestEntity, TestEntityMeta> {
  @override
  bool createTableAt(int newVersion) {
    return switch (newVersion) {
      /// replace dbVersion with the version number this entity was introduced.
      /// remember to update dbVersion to this version
      /// in your OrmContext instance
      _ => false,
    };
  }

  @override
  bool recreateTableAt(int newVersion) {
    return switch (newVersion) {
      _ => false,
    };
  }

  @override
  List<ColumnDefinition<TestEntity, dynamic>> addColumnsAt(
    int newVersion,
  ) {
    return switch (newVersion) {
      _ => [],
    };
  }
}

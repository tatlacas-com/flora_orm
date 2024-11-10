part of 'test.entity.dart';

mixin TestEntityMigrations on Entity<TestEntity, TestEntityMeta> {
  @override
  bool recreateTableAt(int newVersion) {
    return switch (newVersion) {
      4 => true,
      _ => false,
    };
  }

  @override
  List<ColumnDefinition> addColumnsAt(int newVersion) {
    return switch (newVersion) {
      _ => [],
    };
  }
}

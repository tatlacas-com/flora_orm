part of 'user.entity.dart';

mixin UserEntityMigrations on Entity<UserEntity, UserEntityMeta> {
  @override
  bool recreateTableAt(int newVersion) {
    return switch (newVersion) {
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

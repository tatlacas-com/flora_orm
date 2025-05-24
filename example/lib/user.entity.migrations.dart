part of 'user.entity.dart';

mixin UserEntityMigrations on Entity<UserEntity, UserEntityMeta> {
  @override
  bool createTableAt(int newVersion) {
    return switch (newVersion) {
      1 => true,
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
  List<ColumnDefinition<UserEntity, dynamic>> addColumnsAt(int newVersion) {
    return switch (newVersion) {
      _ => [],
    };
  }
}

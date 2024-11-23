part of 'user.entity.dart';

mixin UserEntityMigrations on Entity<UserEntity, UserEntityMeta> {
  @override
  bool createTableAt(int newVersion) {
    return switch (newVersion) {
      /// replace dbVersion with the version number this entity was introduced.
      /// remember to update dbVersion to this version in your OrmManager instance
      // TODO(dev): replace _dbVersion with number
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
  List<ColumnDefinition> addColumnsAt(int newVersion) {
    return switch (newVersion) {
      _ => [],
    };
  }
}

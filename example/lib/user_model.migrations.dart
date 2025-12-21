part of 'user_model.dart';

mixin UserModelMigrations on Model<UserModel, UserModelMeta> {
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
  List<ColumnDefinition<UserModel, dynamic>> addColumnsAt(
    int newVersion,
  ) {
    return switch (newVersion) {
      _ => [],
    };
  }
}

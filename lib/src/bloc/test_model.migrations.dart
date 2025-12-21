part of 'test_model.dart';

mixin TestModelMigrations on Model<TestModel, TestModelMeta> {
  @override
  bool createTableAt(int newVersion) {
    return switch (newVersion) {
      /// replace dbVersion with the version number this model was introduced.
      /// remember to update dbVersion to this version
      /// in your OrmContext instance
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
  List<ColumnDefinition<TestModel, dynamic>> addColumnsAt(
    int newVersion,
  ) {
    return switch (newVersion) {
      _ => [],
    };
  }
}

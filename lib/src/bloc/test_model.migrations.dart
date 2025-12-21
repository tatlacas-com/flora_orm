part of 'test_model.dart';

mixin TestModelMigrations on Model<TestModel, TestModelMeta> {
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
  List<ColumnDefinition<TestModel, dynamic>> addColumnsAt(
    int newVersion,
  ) {
    return switch (newVersion) {
      _ => [],
    };
  }
}

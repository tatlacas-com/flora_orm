part of 'model.dart';

abstract class ModelBase {
  const ModelBase({this.id, this.collectionId, this.createdAt, this.updatedAt});
  final String? id;
  final String? collectionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ModelBase updateDates({DateTime? createdAt});

  ModelBase copyWith({
    String? id,
    String? collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? json,
  });

  ModelMeta get meta;

  List<String> additionalUpgradeQueries(int oldVersion, int newVersion);

  bool recreateTableAt(int newVersion);

  bool createTableAt(int newVersion);

  List<String> recreateTable(int newVersion);

  List<String> downgradeTable(int oldVersion, int newVersion);

  List<String> onUpgradeComplete(int oldVersion, int newVersion);

  List<String> onCreateComplete(int newVersion);

  List<String> onDowngradeComplete(int oldVersion, int newVersion);

  String createTable(int version);

  Map<String, dynamic> toMap();

  Map<String, dynamic> toDb();

  ModelBase load(Map<String, dynamic> json);
}

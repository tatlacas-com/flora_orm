import 'package:tatlacas_sqflite_storage/sql.dart';

class SqlOrder {
  final OrderDirection direction;
  final SqlColumn column;

  const SqlOrder({
    this.direction = OrderDirection.Asc,
    required this.column,
  });
}

enum OrderDirection {
  Asc,
  Desc,
}

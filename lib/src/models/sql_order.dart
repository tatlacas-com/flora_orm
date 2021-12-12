import 'package:equatable/equatable.dart';
import 'package:tatlacas_sqflite_storage/sql.dart';

class SqlOrder extends Equatable {
  final OrderDirection direction;
  final SqlColumn column;

  const SqlOrder({
    this.direction = OrderDirection.Asc,
    required this.column,
  });

  @override
  List<Object?> get props => [direction, column];
}

enum OrderDirection {
  Asc,
  Desc,
}

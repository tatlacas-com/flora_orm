import 'package:equatable/equatable.dart';
import 'package:tatlacas_orm/tatlacas_orm.dart';

class SqlOrder extends Equatable {
  const SqlOrder({
    this.direction = OrderDirection.asc,
    required this.column,
  });
  final OrderDirection direction;
  final SqlColumn column;

  @override
  List<Object?> get props => [direction, column];
}

enum OrderDirection {
  asc,
  desc,
}

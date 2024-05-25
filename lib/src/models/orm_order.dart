import 'package:equatable/equatable.dart';
import 'package:tatlacas_orm/tatlacas_orm.dart';

class OrmOrder extends Equatable {
  const OrmOrder({
    this.direction = OrderDirection.asc,
    required this.column,
  });
  final OrderDirection direction;
  final ColumnDefinition column;

  @override
  List<Object?> get props => [direction, column];
}

enum OrderDirection {
  asc,
  desc,
}

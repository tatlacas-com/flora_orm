import 'package:equatable/equatable.dart';
import 'package:flora_orm/flora_orm.dart';

class OrmOrder<TEntity extends IEntity> extends Equatable {
  const OrmOrder({
    required this.column,
    this.direction = OrderDirection.asc,
  });
  final OrderDirection direction;
  final ColumnDefinition<TEntity, dynamic> column;

  @override
  List<Object?> get props => [direction, column];
}

enum OrderDirection {
  asc,
  desc,
  ;

  String get sortStr => this == desc ? ' DESC' : '';
}

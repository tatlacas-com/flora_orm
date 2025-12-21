import 'package:equatable/equatable.dart';
import 'package:flora_orm/flora_orm.dart';

class OrmOrder<TModel extends ModelBase> extends Equatable {
  const OrmOrder(this.column, {this.direction = OrderDirection.asc});
  final OrderDirection direction;
  final ColumnDefinition<TModel, dynamic> column;

  @override
  List<Object?> get props => [direction, column];
}

enum OrderDirection {
  asc,
  desc;

  String get sortStr => this == desc ? ' DESC' : '';
}

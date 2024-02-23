import 'package:equatable/equatable.dart';

class FormattedQuery extends Equatable {
  const FormattedQuery({required this.whereArgs,required this.where});
  final String where;
  final List<dynamic>? whereArgs;

  @override
  List<Object?> get props => [where,whereArgs];

  @override
  String toString() => 'FormattedQuery {where:$where, whereArgs:$whereArgs}';
}
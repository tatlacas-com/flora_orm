import 'package:equatable/equatable.dart';

class FormattedQuery extends Equatable {
  final String where;
  final List<dynamic>? whereArgs;
  const FormattedQuery({required this.whereArgs,required this.where});

  @override
  List<Object?> get props => [where,whereArgs];

  @override
  String toString() => 'FormattedQuery {where:$where, whereArgs:$whereArgs}';
}
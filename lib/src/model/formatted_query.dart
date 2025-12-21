import 'package:equatable/equatable.dart';

class FormattedQuery extends Equatable {
  const FormattedQuery({required this.whereArgs, required this.filter});
  final String filter;
  final List<dynamic>? whereArgs;

  @override
  List<Object?> get props => [filter, whereArgs];

  @override
  String toString() => 'FormattedQuery {where:$filter, whereArgs:$whereArgs}';
}

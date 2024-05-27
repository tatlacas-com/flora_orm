// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:tatlacas_orm/src/test_entities/copy_with.dart';

import 'package:tatlacas_orm/tatlacas_orm.dart';

part 'animal.entity.g.dart';

@entity
class AnimalEntity extends Entity<AnimalEntity, AnimalEntityMeta>
    with _AnimalEntityMixin {
  AnimalEntity({
    super.id,
    super.createdAt,
    super.updatedAt,
    this.text,
    this.testing,
    this.list,
    this.testing2,
    this.dt,
    this.dt1,
    this.numnum,
    this.num2,
  });

  @column
  final String? text;
  @column
  final List<String>? list;
  @column
  final List<DateTime>? dt;
  @column
  final DateTime? dt1;
  @OrmColumn(isEnum: true)
  final Menum? numnum;
  @OrmColumn(isEnum: true)
  final List<Menum>? num2;
  @column
  final Testing? testing;
  @column
  final List<Testing>? testing2;
}

class Testing extends Equatable {
  Testing({required this.value});

  final String value;

  @override
  List<Object> get props => [value];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'value': value,
    };
  }

  factory Testing.fromMap(Map<String, dynamic> map) {
    return Testing(
      value: map['value'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Testing.fromJson(String source) =>
      Testing.fromMap(json.decode(source) as Map<String, dynamic>);
}

enum Menum {
  a,
  b,
  c,
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
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
    this.textSpans,
    this.numnum,
    this.num2,
    this.num4 = Menum.a,
    this.num6 = const [],
  });

  @override
  @column
  final String? text;
  @override
  @column
  final List<String>? list;
  @override
  @column
  final List<DateTime>? dt;
  @override
  @column
  final DateTime? dt1;
  @override
  @OrmColumn(isEnum: true)
  final Menum? numnum;
  @override
  @OrmColumn(isEnum: true)
  final Menum num4;
  @override
  @OrmColumn(isEnum: true)
  final List<Menum>? num2;
  @override
  @OrmColumn(isEnum: true)
  final List<Menum> num6;
  @override
  @column
  final Testing? testing;
  @override
  @column
  final List<Testing>? testing2;

  @override
  final List<TextSpan>? textSpans;
}

class Testing extends Equatable {
  const Testing({required this.value});

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

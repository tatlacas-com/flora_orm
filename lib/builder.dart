library tatlacas_sqflite_storage.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tatlacas_orm/src/builders/db_column_generator.dart';

Builder dbColumnsBuilder(BuilderOptions options) =>
    SharedPartBuilder([DbColumnGenerator()], 'db_columns');

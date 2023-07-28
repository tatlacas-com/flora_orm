library tatlacas_sqflite_storage.builder;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder dbColumnsBuilder(BuilderOptions options) =>
    SharedPartBuilder([MultiplierGenerator()], 'multiply');

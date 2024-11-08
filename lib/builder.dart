library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flora_orm/src/builders/entity_props_generator.dart';

Builder entityPropsBuilder(BuilderOptions options) =>
    SharedPartBuilder([EntityPropsGenerator()], 'entityPropsBuilder',
        additionalOutputExtensions: ['mg.dart']);

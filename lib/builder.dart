import 'package:build/build.dart';
import 'package:flora_orm/src/builder/model_props_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder modelPropsBuilder(BuilderOptions options) =>
    SharedPartBuilder([ModelPropsGenerator()], 'modelPropsBuilder');

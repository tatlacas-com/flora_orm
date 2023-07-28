// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tatlacas_sqflite_storage/annotations.dart';

class DbColumnGenerator extends GeneratorForAnnotation<DbColumn> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // Ensure that the annotated element is a field
    if (element is! FieldElement) {
      throw InvalidGenerationSourceError(
        'The @DbColumn annotation can only be used on fields.',
        element: element,
      );
    }
// Get the enclosing class name
    final enclosingClassName = element.enclosingElement.name;

    final fieldName = element.name;
    final fieldType = element.type.getDisplayString(withNullability: false);

    // Here, you can access other information from the annotation, such as saveToDb and readFromDb.
    // For simplicity, we will omit them in this example.

    final generatedCode = '''
      SqlColumn<$enclosingClassName, $fieldType> get column$fieldName =>
        SqlColumn<$enclosingClassName, $fieldType>(
          '$fieldName',
          saveToDb: (entity) => entity.$fieldName,
          readFromDb: (entity, value) => entity.copyWith($fieldName: value),
        );
    ''';

    return generatedCode;
  }
}

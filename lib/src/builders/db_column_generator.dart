import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tatlacas_sqflite_storage/src/annotations.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:tatlacas_sqflite_storage/src/models/entity.dart';

class DbColumnGenerator extends GeneratorForAnnotation<DbEntity> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final classElement = element as ClassElement;
    final className = classElement.name;
    if (!TypeChecker.fromRuntime(Entity).isAssignableFrom(element)) {
      throw new Exception('$className is not an Entity class');
    }

    final fields = classElement.fields;

    final generatedCode = StringBuffer();
    final columnsList = StringBuffer();
    final extendedClassName =
        element.supertype?.getDisplayString(withNullability: false);

    generatedCode.writeln('mixin _${className}Mixin on $extendedClassName {');

    generatedCode.writeln('''
  @override
  String get tableName => '${convertClassNameToSnakeCase(className)}';
    ''');
    for (final field in fields) {
      if (TypeChecker.fromRuntime(DbColumn).hasAnnotationOfExact(field)) {
        final fieldName = field.name;
        final fieldNameCamel = _toUpperCamelCase(fieldName);
        final fieldType = field.type.getDisplayString(withNullability: false);

        columnsList.writeln('column$fieldNameCamel,');
        generatedCode.writeln('''
      SqlColumn<$className, $fieldType> get column$fieldNameCamel =>
        SqlColumn<$className, $fieldType>(
          '$fieldName',
          saveToDb: (entity) => entity.$fieldName,
          readFromDb: (entity, value) => entity.copyWith($fieldName: value),
        );
    ''');
      }
    }
    generatedCode.writeln('''
      @override
      Iterable<SqlColumn<$className, dynamic>> get columns => [
      $columnsList
      ];''');

    generatedCode.writeln('}');

    return generatedCode.toString();
  }

  // Helper function to convert the first letter of a string to uppercase
  String _toUpperCamelCase(String input) {
    return input[0].toUpperCase() + input.substring(1);
  }

  String convertClassNameToSnakeCase(String className) {
    final buffer = StringBuffer();
    bool isFirstLetter = true;

    for (final char in className.runes) {
      if (isFirstLetter) {
        buffer.write(String.fromCharCode(char).toLowerCase());
        isFirstLetter = false;
      } else if (String.fromCharCode(char).toUpperCase() ==
          String.fromCharCode(char)) {
        buffer.write('_${String.fromCharCode(char).toLowerCase()}');
      } else {
        buffer.write(String.fromCharCode(char));
      }
    }

    return buffer.toString();
  }
}

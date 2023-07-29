import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tatlacas_sqflite_storage/src/builders/annotations.dart';
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
    final tableName = annotation.read('tableName').literalValue as String?;

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
  String get tableName => '${tableName ?? convertClassNameToSnakeCase(className)}';
    ''');
    for (final field in fields) {
      if (TypeChecker.fromRuntime(DbColumn).hasAnnotationOfExact(field)) {
        final fieldName = field.name;
        final fieldNameCamel = _toUpperCamelCase(fieldName);
        final fieldType = field.type.getDisplayString(withNullability: false);

        columnsList.writeln('column$fieldNameCamel,');
        final metadata = field.metadata;
        for (final annotationElement in metadata) {
          final element = annotationElement.element;
          if (element != null &&
              TypeChecker.fromRuntime(DbColumn).isExactly(element)) {
            // Get the constructor arguments of the DbColumn annotation
            final constantObj = annotationElement.computeConstantValue();

            final String name =
                constantObj?.getField('name')?.toStringValue() ?? fieldName;
            final String? alias =
                constantObj?.getField('alias')?.toStringValue();
            final bool jsonEncodeAlias =
                constantObj?.getField('jsonEncodeAlias')?.toBoolValue() ??
                    false;
            final bool primaryKey =
                constantObj?.getField('primaryKey')?.toBoolValue() ?? false;
            final bool autoIncrementPrimary =
                constantObj?.getField('autoIncrementPrimary')?.toBoolValue() ??
                    false;
            final bool notNull =
                constantObj?.getField('notNull')?.toBoolValue() ?? false;
            final bool unique =
                constantObj?.getField('unique')?.toBoolValue() ?? false;
            final dynamic defaultValue =
                constantObj?.getField('defaultValue')?.toStringValue();

            generatedCode.writeln('''
      SqlColumn<$className, $fieldType> get column$fieldNameCamel =>
        SqlColumn<$className, $fieldType>(
          '$name',
    ''');
            if (alias != null) {
              generatedCode.writeln('''
           alias: '$alias',
    ''');
            }
            if (jsonEncodeAlias == true) {
              generatedCode.writeln('''
           jsonEncodeAlias: $jsonEncodeAlias,
    ''');
            }
            if (primaryKey == true) {
              generatedCode.writeln('''
           primaryKey: $primaryKey,
    ''');
            }
            if (unique == true) {
              generatedCode.writeln('''
           unique: $unique,
    ''');
            }
            if (autoIncrementPrimary == true) {
              generatedCode.writeln('''
           autoIncrementPrimary: $autoIncrementPrimary,
    ''');
            }
            if (notNull == true) {
              generatedCode.writeln('''
           notNull: $notNull,
    ''');
            }
            if (defaultValue != null) {
              if (field.type.isDartCoreString) {
                generatedCode.writeln('''
           defaultValue: '$defaultValue',
    ''');
              } else {
                generatedCode.writeln('''
           defaultValue: $defaultValue,
    ''');
              }
            }
            generatedCode.writeln('''
          saveToDb: (entity) => entity.$fieldName,
          readFromDb: (entity, value) => entity.copyWith($fieldName: value),
        );
    ''');

            break;
          }
        }
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

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
    final hasSuperColumns =
        annotation.read('hasSuperColumns').literalValue as bool? ?? false;

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
        final fieldAnnotations = field.metadata.where((annotation) {
          final tp = annotation.computeConstantValue()?.type;
          return tp != null &&
              TypeChecker.fromRuntime(DbColumn).isExactlyType(tp);
        });

        for (final annotation in fieldAnnotations) {
          final dbColumnAnnotation = annotation.computeConstantValue()!;

          final String name =
              dbColumnAnnotation.getField('name')?.toStringValue() ?? fieldName;
          final jsonEncoded =
              dbColumnAnnotation.getField('encodedJson')?.toBoolValue() ??
                  false;
          final String? alias =
              dbColumnAnnotation.getField('alias')?.toStringValue() ??
                  (jsonEncoded ? fieldName.replaceAll('Json', '') : null);

          final bool hasReadFromDb =
              dbColumnAnnotation.getField('hasReadFromDb')?.toBoolValue() ??
                  false;
          final bool hasSaveToDb =
              dbColumnAnnotation.getField('hasSaveToDb')?.toBoolValue() ??
                  false;
          final bool primaryKey =
              dbColumnAnnotation.getField('primaryKey')?.toBoolValue() ?? false;
          final bool autoIncrementPrimary = dbColumnAnnotation
                  .getField('autoIncrementPrimary')
                  ?.toBoolValue() ??
              false;
          final bool notNull =
              dbColumnAnnotation.getField('notNull')?.toBoolValue() ?? false;
          final bool unique =
              dbColumnAnnotation.getField('unique')?.toBoolValue() ?? false;
          dynamic defaultValue = dbColumnAnnotation.getField('defaultValue');
          if (field.type.isDartCoreBool) {
            defaultValue =
                dbColumnAnnotation.getField('defaultValue')?.toBoolValue();
          } else if (field.type.isDartCoreInt) {
            defaultValue =
                dbColumnAnnotation.getField('defaultValue')?.toIntValue();
          } else if (field.type.isDartCoreDouble) {
            defaultValue =
                dbColumnAnnotation.getField('defaultValue')?.toDoubleValue();
          } else {
            defaultValue =
                dbColumnAnnotation.getField('defaultValue')?.toStringValue();
          }
          var columnType = fieldType;
          String? jsonEncodedType;
          final annotationSource = annotation.toSource().trim();

          final start = annotationSource.indexOf('<');
          final end = annotationSource.indexOf('>');
          if (start != -1) {
            final t = annotationSource.substring(start + 1, end);
            if (jsonEncoded) {
              jsonEncodedType = t;
            } else {
              columnType = t;
            }
          }

          if (hasReadFromDb) {
            generatedCode.writeln('''
  $className read${fieldNameCamel}FromDb(value, $className entity);
 ''');
          } else if (jsonEncoded) {
            generatedCode.writeln('''
  $className read${fieldNameCamel}FromDb(value, $className entity){
    $jsonEncodedType? $alias;
    if (value != null) {
      Map<String, dynamic> map = jsonDecode(value);
      $alias = $jsonEncodedType.fromMap(map);
    }
    return entity.copyWith(
      $fieldName: value,
      $alias: $alias,
    );
  }
 ''');
          }
          if (hasSaveToDb) {
            generatedCode.writeln('''
  $columnType? save${fieldNameCamel}ToDb($className entity);
 ''');
          }

          generatedCode.writeln('''
      SqlColumn<$className, $columnType> get column$fieldNameCamel =>
        SqlColumn<$className, $columnType>(
          '$name',
    ''');
          if (alias != null) {
            generatedCode.writeln('''
           alias: '$alias',
    ''');
          }
          if (jsonEncoded) {
            generatedCode.writeln('''
           jsonEncodeAlias: $jsonEncoded,
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
          if (hasSaveToDb) {
            generatedCode.writeln('''
          saveToDb: (entity) => save${fieldNameCamel}ToDb(entity),
    ''');
          } else if (jsonEncoded) {
            generatedCode.writeln('''
          saveToDb: (entity) => jsonEncode(entity.$alias,
              toEncodable: (value) => (value as jsonEncodedType?)?.toMap()),
    ''');
          } else {
            generatedCode.writeln('''
          saveToDb: (entity) => entity.$fieldName,
    ''');
          }
          if (hasReadFromDb) {
            generatedCode.writeln('''
          readFromDb: (entity, value) => read${fieldNameCamel}FromDb(value, entity),
        );
    ''');
          } else if (jsonEncoded) {
            generatedCode.writeln('''
          readFromDb: (entity, value){
            if ('null' == value){
              return read${fieldNameCamel}FromDb(null, entity);
            }
            return read${fieldNameCamel}FromDb(value, entity);
          },
        );
    ''');
          } else {
            generatedCode.writeln('''
          readFromDb: (entity, value) => entity.copyWith($fieldName: value),
        );
    ''');
          }
        }
      }
    }
    generatedCode.writeln('''
      @override
      Iterable<SqlColumn<$className, dynamic>> get columns => [
      ''');
    if (hasSuperColumns) {
      generatedCode.writeln('''
      ...super.columns,
      ''');
    }
    generatedCode.writeln('''
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

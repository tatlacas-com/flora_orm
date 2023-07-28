import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tatlacas_sqflite_storage/src/annotations.dart';

class DbColumnGenerator extends GeneratorForAnnotation<DbEntity> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    final classElement = element as ClassElement;

    final className = classElement.name;
    final fields = classElement.fields;

    final generatedCode = StringBuffer();
    final columnsList = StringBuffer();

    generatedCode.writeln('extension ${className}Extension on $className {');

    for (final field in fields) {
      if (TypeChecker.fromRuntime(DbColumn).hasAnnotationOfExact(field)) {
        final fieldName = field.name;
        final fieldType = field.type.getDisplayString(withNullability: false);

        columnsList.writeln('column$fieldName,');
        generatedCode.writeln('''
      SqlColumn<$className, $fieldType> get column$fieldName =>
        SqlColumn<$className, $fieldType>(
          '$fieldName',
          saveToDb: (entity) => entity.$fieldName,
          readFromDb: (entity, value) => entity.copyWith($fieldName: value),
        );
    ''');
      }
    }
    generatedCode.writeln('');
    generatedCode.writeln('''
      @override
      static final Iterable<SqlColumn<$className, dynamic>> columns = [
      $columnsList
      ]''');

    generatedCode.writeln('}');

    return generatedCode.toString();
  }
}

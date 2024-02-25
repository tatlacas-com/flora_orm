import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:tatlacas_sqflite_storage/src/builders/annotations.dart';
import 'package:tatlacas_sqflite_storage/src/models/entity.dart';

class _ExtraField {
  _ExtraField({
    required this.notNull,
    required this.type,
    required this.typeFull,
  });

  final bool notNull;
  final String type;
  final String typeFull;
}

// Define a visitor class to search for a property with a specific name.
class PropertyFinder extends RecursiveElementVisitor<void> {
  PropertyFinder(this.propertyName);
  final String propertyName;
  FieldElement? foundProperty;

  @override
  void visitFieldElement(FieldElement element) {
    if (element.name == propertyName) {
      foundProperty = element;
    }
  }
}

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

    if (!const TypeChecker.fromRuntime(Entity).isAssignableFrom(element)) {
      throw Exception('$className is not an Entity class');
    }

    final fields = classElement.fields;

    final generatedCode = StringBuffer();
    final columnsList = StringBuffer();
    final copyWithList = StringBuffer();
    final getList = StringBuffer();
    final copyWithPropsList = StringBuffer();
    final propsList = StringBuffer();

    final extendedClassName =
        element.supertype?.getDisplayString(withNullability: false);

    generatedCode.writeln('mixin _${className}Mixin on $extendedClassName {');

    generatedCode.writeln('''
  @override
  String get tableName => '${tableName ?? convertClassNameToSnakeCase(className)}';
    ''');
    final Map<String, _ExtraField> extraFields = {};
    extraFields.addEntries(
      fields
          .where((element) => element.metadata.isEmpty)
          .map(
            (e) => MapEntry(
              e.name,
              _ExtraField(
                type: e.type.getDisplayString(withNullability: false),
                typeFull: e.type.getDisplayString(withNullability: true),
                notNull: e.type.nullabilitySuffix == NullabilitySuffix.none,
              ),
            ),
          )
          .toList(),
    );
    for (final field in fields) {
      if (const TypeChecker.fromRuntime(DbColumn).hasAnnotationOfExact(field)) {
        final fieldName = field.name;
        final fieldType = field.type.getDisplayString(withNullability: false);
        final fieldTypeFull =
            field.type.getDisplayString(withNullability: true);
        final fieldNameCamel = _toUpperCamelCase(fieldName);
        final fieldMetadata = field.metadata;
        final List<ElementAnnotation> fieldAnnotations = [];
        for (final annotation in fieldMetadata) {
          final tp = annotation.computeConstantValue()?.type;
          if (tp == null) {
            continue;
          }
          if (const TypeChecker.fromRuntime(DbColumn).isExactlyType(tp)) {
            columnsList.writeln('column$fieldNameCamel,');
            fieldAnnotations.add(annotation);
          }
        }

        propsList.writeln('$fieldName,');
        getList.writeln('$fieldTypeFull get $fieldName;');

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

          final String? writeFn =
              dbColumnAnnotation.getField('writeFn')?.toStringValue();

          final bool hasRead =
              dbColumnAnnotation.getField('hasRead')?.toBoolValue() ?? false;
          final bool hasWrite =
              dbColumnAnnotation.getField('hasWrite')?.toBoolValue() ?? false;
          final bool primaryKey =
              dbColumnAnnotation.getField('primaryKey')?.toBoolValue() ?? false;
          final bool autoIncrementPrimary = dbColumnAnnotation
                  .getField('autoIncrementPrimary')
                  ?.toBoolValue() ??
              false;
          final bool notNull =
              dbColumnAnnotation.getField('notNull')?.toBoolValue() ??
                  (field.type.nullabilitySuffix == NullabilitySuffix.none);
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
          FieldElement? aliasProperty;
          bool aliasNotNull = false;
          if (alias != null && (hasRead || jsonEncoded)) {
            final finder = PropertyFinder(alias);
            classElement.accept(finder);
            aliasProperty = finder.foundProperty!;
            aliasNotNull =
                aliasProperty.type.nullabilitySuffix == NullabilitySuffix.none;
            if (aliasProperty.type.isDartCoreList) {
              jsonEncodedType =
                  aliasProperty.type.getDisplayString(withNullability: false);
            }
            generatedCode.writeln('''
  $jsonEncodedType? get $alias;
 ''');
          }
          if (hasRead) {
            generatedCode.writeln('''
  $className read$fieldNameCamel(Map<String, dynamic> json, value, $className entity);
 ''');
          } else if (jsonEncoded) {
            generatedCode.writeln('''
  $className read$fieldNameCamel(Map<String, dynamic> json, value, $className entity){
    $jsonEncodedType? $alias;
    final val = value != null && value != 'null' ? value : null;
    if (val != null) {
      Map<String, dynamic> map = jsonDecode(val);
      $alias = $jsonEncodedType.fromMap(map);
    }
    return entity.copyWith(
      $fieldName: ${notNull ? 'val' : 'CopyWith(val)'},
      $alias: ${aliasNotNull ? alias : 'CopyWith($alias)'},
      json: json,
    );
  }
 ''');
          }
          if (hasWrite) {
            generatedCode.writeln('''
  $columnType? write$fieldNameCamel($className entity);
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
          if (hasWrite) {
            generatedCode.writeln('''
          write: (entity) => write$fieldNameCamel(entity),
    ''');
          } else if (jsonEncoded) {
            generatedCode.writeln('''
          write: (entity) {
    ''');
            final finder = PropertyFinder(alias!);
            classElement.accept(finder);
            final property = finder.foundProperty!;
            if (property.type.isDartCoreList) {
              jsonEncodedType =
                  property.type.getDisplayString(withNullability: false);
              generatedCode.writeln('''
            final map = entity.$alias?.map((p) => p.toMap()).toList();
    ''');
            } else {
              generatedCode.writeln('''
            final map = entity.$alias?.${writeFn ?? 'toMap'}();
    ''');
            }
            generatedCode.writeln('''
            return jsonEncode(map);
            },
    ''');
          } else {
            generatedCode.writeln('''
          write: (entity) => entity.$fieldName,
    ''');
          }
          if (hasRead || jsonEncoded) {
            if (jsonEncoded) {
              if (alias != null) {
                if (aliasNotNull) {
                  copyWithPropsList.writeln('$jsonEncodedType? $alias,');
                  copyWithList.writeln('$alias: $alias ?? this.$alias,');
                } else {
                  copyWithPropsList
                      .writeln('CopyWith<$jsonEncodedType?>? $alias,');
                  copyWithList.writeln(
                      '$alias: $alias != null ? $alias.value : this.$alias,');
                }
                if (extraFields.containsKey(alias)) {
                  extraFields.remove(alias);
                }
              }
              generatedCode.writeln('''
          read: (json, entity, value){
            if ('null' == value){
              return read$fieldNameCamel(json, null, entity);
            }
            return read$fieldNameCamel(json, value, entity);
          },
        );
    ''');
            } else {
              generatedCode.writeln('''
          read: (json, entity, value) => read$fieldNameCamel(json, value, entity),
        );
    ''');
            }
          } else if (notNull) {
            generatedCode.writeln('''
          read: (json, entity, value) => entity.copyWith($fieldName: value, json: json),
        );
    ''');
          } else {
            generatedCode.writeln('''
          read: (json, entity, value) => entity.copyWith($fieldName: CopyWith(value), json: json),
        );
    ''');
          }
          if (notNull) {
            copyWithPropsList.writeln('$fieldType? $fieldName,');
            copyWithList.writeln('$fieldName: $fieldName ?? this.$fieldName,');
          } else {
            copyWithPropsList.writeln('CopyWith<$fieldType?>? $fieldName,');
            copyWithList.writeln(
                '$fieldName: $fieldName != null ? $fieldName.value : this.$fieldName,');
          }

          if (extraFields.containsKey(fieldName)) {
            extraFields.remove(fieldName);
          }
        }
      } else if (const TypeChecker.fromRuntime(NullableProp)
          .hasAnnotationOfExact(field)) {
        final fieldName = field.name;
        final fieldType = field.type.getDisplayString(withNullability: false);
        final fieldTypeFull =
            field.type.getDisplayString(withNullability: true);
        extraFields[fieldName] = _ExtraField(
          type: fieldType,
          notNull: false,
          typeFull: fieldTypeFull,
        );
      }
    }
    for (final fieldName in extraFields.keys) {
      final extraField = extraFields[fieldName]!;

      propsList.writeln('$fieldName,');
      getList.writeln('${extraField.type} get $fieldName;');
      if (extraField.notNull) {
        copyWithPropsList.writeln('${extraField.type}? $fieldName,');
        copyWithList.writeln('$fieldName: $fieldName ?? this.$fieldName,');
      } else {
        copyWithPropsList.writeln('CopyWith<${extraField.type}?>? $fieldName,');
        copyWithList.writeln(
            '$fieldName: $fieldName != null ? $fieldName.value : this.$fieldName,');
      }
    }
    generatedCode.writeln(getList);
    generatedCode.writeln('''

      @override
      List<Object?> get props => [
        ...super.props,
      ''');
    generatedCode.writeln('''
      $propsList
      ];''');

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

    generatedCode.writeln('''
      @override
      $className copyWith({
        String? id,
        DateTime? createdAt,
        DateTime? updatedAt,
        $copyWithPropsList
        Map<String, dynamic>? json,
      }){
        return $className(
          id: id ?? this.id,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          $copyWithList
        );
      }''');
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

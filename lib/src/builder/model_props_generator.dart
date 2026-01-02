// ignore_for_file: leading_newlines_in_multiline_strings

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:flora_orm/src/builder/annotations.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

extension DartTypeExtension on DartType {
  String get cleanDisplayString =>
      getDisplayString().replaceFirst(RegExp('[?*]'), '');

  bool get isEnum {
    if (this is InterfaceType) {
      final element = this.element! as InterfaceElement;
      return element is EnumElement;
    }
    return false;
  }
}

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

FieldElement? _findFieldByName(ClassElement classElement, String propertyName) {
  for (final field in classElement.fields) {
    if (field.name == propertyName) {
      return field;
    }
  }

  for (final supertype in classElement.allSupertypes) {
    if (supertype.element is ClassElement) {
      final superClass = supertype.element as ClassElement;
      for (final field in superClass.fields) {
        if (field.name == propertyName) {
          return field;
        }
      }
    }
  }

  return null;
}

class ModelPropsGenerator extends GeneratorForAnnotation<OrmModel> {
  static const _ormColumnChecker = TypeChecker.typeNamedLiterally(
    'OrmColumn',
    inPackage: 'flora_orm',
  );
  static const _copyablePropChecker = TypeChecker.typeNamedLiterally(
    'CopyableProp',
    inPackage: 'flora_orm',
  );
  static const _nullablePropChecker = TypeChecker.typeNamedLiterally(
    'NullableProp',
    inPackage: 'flora_orm',
  );
  static const _modelChecker = TypeChecker.typeNamedLiterally(
    'Model',
    inPackage: 'flora_orm',
  );

  bool _hasDbAnnotation(FieldElement field) {
    return _ormColumnChecker.hasAnnotationOfExact(field) ||
        _copyablePropChecker.hasAnnotationOfExact(field) ||
        _nullablePropChecker.hasAnnotationOfExact(field);
  }

  static const _excludedSuperClasses = [
    'Model',
    'Equatable',
    'ModelBase',
    'Object',
  ];

  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final classElement = element as ClassElement;
    final className = classElement.name;

    final tableName = annotation.read('tableName').literalValue as String?;

    if (!_modelChecker.isAssignableFrom(element)) {
      throw Exception('$className is not an Model class');
    }

    final allFields = <FieldElement>[...classElement.fields];
    for (final supertype in classElement.allSupertypes) {
      if (supertype.element is ClassElement) {
        final superClass = supertype.element as ClassElement;
        // Filter out Object and other system classes if needed
        if (!_excludedSuperClasses.contains(superClass.name)) {
          allFields.addAll(superClass.fields);
        }
      }
    }
    final mixinCode = StringBuffer();
    final metaCode = StringBuffer();
    final columnsList = StringBuffer();
    final copyWithList = StringBuffer();
    final getList = StringBuffer();
    final copyWithPropsList = StringBuffer();
    final propsList = StringBuffer();

    mixinCode.writeln(
      'mixin _${className}Mixin on Model<$className, ${className}Meta> {',
    );
    metaCode
      ..writeln('''
typedef ${className}Store
    = OrmEngine<$className, ${className}Meta, StoreContext<$className>>;

class ${className}Meta extends  ModelMeta<$className> {     
  const ${className}Meta();

  @override
  String get tableName => '${tableName ?? convertClassNameToSnakeCase(className!)}';
          ''')
      ..writeln('''
  @override
  ColumnDefinition<$className, String> get id => 
  ColumnDefinition<$className, String>(
        'id',
        primaryKey: true,
        write: (model) => model.id,
        read: (json, model, value) =>
            model.copyWith(id: value as String?, json: json),
      );

  @override
  ColumnDefinition<$className, String> get collectionId => 
  ColumnDefinition<$className, String>(
        'collectionId',
        write: (model) => model.collectionId,
        read: (json, model, value) =>
            model.copyWith(collectionId: value as String?, json: json),
      );

  @override
  ColumnDefinition<$className, DateTime> get createdAt =>
      ColumnDefinition<$className, DateTime>(
        'createdAt',
        write: (model) => model.createdAt,
        read: (json, model, value) =>
            model.copyWith(createdAt: value as DateTime?, json: json),
      );

  @override
  ColumnDefinition<$className, DateTime> get updatedAt =>
      ColumnDefinition<$className, DateTime>(
        'updatedAt',
        write: (model) => model.updatedAt,
        read: (json, model, value) =>
            model.copyWith(updatedAt: value as DateTime?, json: json),
      );
    ''');

    mixinCode.writeln('''
  
  static const ${className}Meta _meta = ${className}Meta();

  @override
  ${className}Meta get meta => _meta;
    ''');
    final extraFields = <String, _ExtraField>{}
      ..addEntries(
        allFields
            .where(
              (field) =>
                  field.isFinal &&
                  !field.isConst &&
                  !field.isLate &&
                  !field.hasImplicitType &&
                  !field.isPrivate &&
                  !field.hasInitializer &&
                  !field.isStatic &&
                  !_hasDbAnnotation(field),
            )
            .map(
              (e) => MapEntry(
                e.name!,
                _ExtraField(
                  type: e.type.cleanDisplayString,
                  typeFull: e.type.getDisplayString(),
                  notNull: e.type.nullabilitySuffix == NullabilitySuffix.none,
                ),
              ),
            )
            .toList(),
      );
    for (final field in allFields) {
      if (_ormColumnChecker.hasAnnotationOfExact(field)) {
        final fieldName = field.name;
        var fieldType = field.type.cleanDisplayString;

        final fieldTypeFull = field.type.getDisplayString();

        bool premitiveType(String fieldType) {
          return [
            'String',
            'DateTime',
            'int',
            'bool',
            'double',
          ].contains(fieldType);
        }

        final isPremitiveType = premitiveType(fieldType);

        final isList = fieldType.startsWith('List');
        if (isList) {
          final start = fieldTypeFull.indexOf('<');
          final end = fieldTypeFull.indexOf('>');
          if (start != -1) {
            fieldType = fieldTypeFull.substring(start + 1, end);
          }
        }
        final ogIsPremitiveType = premitiveType(fieldType);

        final fieldNameCamel = _toUpperCamelCase(fieldName!);
        final fieldAnnotations = <ElementAnnotation>[];
        for (final annotation in field.metadata.annotations) {
          final tp = annotation.computeConstantValue()?.type;
          if (tp == null) {
            continue;
          }
          if (_ormColumnChecker.isExactlyType(tp)) {
            columnsList.writeln('$fieldName,');
            fieldAnnotations.add(annotation);
          }
        }

        propsList.writeln('$fieldName,');
        getList.writeln('$fieldTypeFull get $fieldName;');

        for (final annotation in fieldAnnotations) {
          final dbColumnAnnotation = annotation.computeConstantValue()!;
          final isEnum = field.type.isEnum;

          final name =
              dbColumnAnnotation.getField('name')?.toStringValue() ?? fieldName;
          final jsonEncoded = !isPremitiveType;
          final alias = dbColumnAnnotation.getField('alias')?.toStringValue();

          final writeFn = dbColumnAnnotation
              .getField('writeFn')
              ?.toStringValue();

          final readFn = dbColumnAnnotation.getField('readFn')?.toStringValue();

          final primaryKey =
              isPremitiveType &&
              (dbColumnAnnotation.getField('primaryKey')?.toBoolValue() ??
                  false);
          final autoIncrementPrimary =
              isPremitiveType &&
              (dbColumnAnnotation
                      .getField('autoIncrementPrimary')
                      ?.toBoolValue() ??
                  false);
          final notNull =
              dbColumnAnnotation.getField('notNull')?.toBoolValue() ??
              (field.type.nullabilitySuffix == NullabilitySuffix.none);
          final unique =
              isPremitiveType &&
              (dbColumnAnnotation.getField('unique')?.toBoolValue() ?? false);
          final df = dbColumnAnnotation.getField('defaultValue');
          dynamic defaultValue;
          if (field.type.isDartCoreBool) {
            defaultValue = df?.toBoolValue();
          } else if (field.type.isDartCoreInt) {
            defaultValue = df?.toIntValue();
          } else if (field.type.isDartCoreDouble) {
            defaultValue = df?.toDoubleValue() ?? df?.toIntValue();
          } else {
            defaultValue = df?.toStringValue();
            if (defaultValue == null && df != null && df.isNull != true) {
              throw ArgumentError(
                'Cannot save the supplied defaultValue for ${field.name}. '
                'Make sure defaultValue is of type bool, int, double or String',
              );
            }
          }
          var columnType = fieldType;
          String? jsonEncodedType;
          final annotationSource = annotation.toSource().trim();

          if (isPremitiveType) {
            final start = annotationSource.indexOf('<');
            final end = annotationSource.indexOf('>');
            if (start != -1) {
              final t = annotationSource.substring(start + 1, end);
              if (jsonEncoded && isPremitiveType) {
                jsonEncodedType = t;
              } else {
                columnType = t;
              }
            }
          } else {
            columnType = 'String';
          }

          FieldElement? aliasProperty;
          var aliasNotNull = false;
          if (alias != null && jsonEncoded) {
            aliasProperty = _findFieldByName(classElement, alias);
            if (aliasProperty == null) {
              throw Exception(
                '''Could not find field "$alias" referenced as alias in $className''',
              );
            }
            aliasNotNull =
                aliasProperty.type.nullabilitySuffix == NullabilitySuffix.none;
            if (aliasProperty.type.isDartCoreList) {
              jsonEncodedType = aliasProperty.type.cleanDisplayString;
            }
            mixinCode.writeln('''
  $jsonEncodedType${aliasNotNull ? '' : '?'} get $alias;
 ''');
          }

          if (readFn != null) {
            mixinCode.writeln('''
  $fieldType $readFn(Map<String, dynamic> json, Map<String, dynamic> value);
 ''');
          }

          if (!isPremitiveType) {
            mixinCode.writeln('''
  $className read$fieldNameCamel(Map<String, dynamic> json, dynamic value){
 ''');
            if (isList) {
              final fnName = readFn != null
                  ? '$readFn(json, e)'
                  : '$fieldType.fromMap(e as Map<String, dynamic>)';
              final map = ogIsPremitiveType
                  ? (fieldType == 'DateTime'
                        ? 'DateTime.parse(e as String)'
                        : 'e as $fieldType')
                  : (isEnum
                        ? '''<$fieldType?>[...$fieldType.values].firstWhere(
          (element) => element?.name == value as String,
          orElse: () => null)'''
                        : fnName);
              mixinCode.writeln('''
    List<$fieldType>? items;
    if (value != null) {
      final list = value is List ? value : jsonDecode(value as String);
      items =
          (list as List<dynamic>?)?.map<$fieldType>((e) => $map).toList();
    }
    return copyWith(
      $fieldName: ${notNull ? 'items' : '()=>items'},
    );
  }
 ''');
            } else {
              late final String fnName;
              if (readFn != null) {
                fnName = '$readFn(json, map)';
              } else if (field.type.isDartCoreMap) {
                fnName = 'map.cast${fieldType.replaceFirst('Map', '')}()';
              } else {
                fnName = '$fieldType.fromMap(map as Map<String, dynamic>)';
              }

              mixinCode.writeln('''
    $fieldType? item;
    if (value != null) {
      ${isEnum ? '' : 'final map = value is Map<String, dynamic> ? value : jsonDecode(value as String);'}
      item = ${isEnum ? '''<$fieldType?>[...$fieldType.values].firstWhere(
          (element) => element?.name == value as String,
          orElse: () => null)''' : fnName} ;
    }
    return copyWith(
      $fieldName: ${notNull ? 'item' : '()=>item'},
    );
  }
 ''');
            }
          }

          if (jsonEncoded && isPremitiveType) {
            final fnName = readFn != null
                ? '$readFn(json, map)'
                : '$jsonEncodedType.fromMap(map)';

            mixinCode
              ..writeln('''
  $className read$fieldNameCamel(Map<String, dynamic> json, dynamic value){
    $jsonEncodedType? $alias;
    final val = value != null && value != 'null' ? value : null;
    if (val != null) {
      Map<String, dynamic> map = val is Map<String, dynamic> ? val : jsonDecode(val);
''')
              ..writeln('''
      $alias = $fnName;
    }
    return copyWith(
      $fieldName: ${notNull ? 'val' : '()=>val'},
      $alias: ${aliasNotNull ? alias : '()=>$alias'},
      json: json,
    );
  }
 ''');
          }

          metaCode.writeln('''
      ColumnDefinition<$className, $columnType> get $fieldName =>
        ColumnDefinition<$className, $columnType>(
          '$name',
    ''');
          if (alias != null) {
            metaCode.writeln('''
           alias: '$alias',
    ''');
          }
          if (jsonEncoded && isPremitiveType) {
            metaCode.writeln('''
           jsonEncodeAlias: $jsonEncoded,
    ''');
          }
          if (primaryKey == true) {
            metaCode.writeln('''
           primaryKey: $primaryKey,
    ''');
          }
          if (unique == true) {
            metaCode.writeln('''
           unique: $unique,
    ''');
          }
          if (autoIncrementPrimary == true) {
            metaCode.writeln('''
           autoIncrementPrimary: $autoIncrementPrimary,
    ''');
          }
          if (notNull == true) {
            metaCode.writeln('''
           notNull: $notNull,
    ''');
          }
          if (defaultValue != null) {
            if (field.type.isDartCoreString || isEnum) {
              metaCode.writeln('''
           defaultValue: '$defaultValue',
    ''');
            } else {
              metaCode.writeln('''
           defaultValue: ${jsonEncoded ? 'jsonEncode($defaultValue)' : defaultValue},
    ''');
            }
          }

          var isDartCoreList = !isPremitiveType && isList;
          if (jsonEncoded && isPremitiveType) {
            final property = _findFieldByName(classElement, alias!);
            if (property == null) {
              throw Exception(
                '''Could not find field "$alias" referenced as alias in $className''',
              );
            }
            isDartCoreList = property.type.isDartCoreList;
            jsonEncodedType = property.type.cleanDisplayString;
          }
          final isNotNull = isPremitiveType ? aliasNotNull : notNull;
          if (jsonEncoded) {
            final typeName = isPremitiveType ? alias : fieldName;
            metaCode.writeln('''
          write: (model) {
            final $typeName = model.$typeName;
    ''');

            if (isDartCoreList) {
              if (isNotNull) {
                metaCode.writeln('''
            if ($typeName.isEmpty) {
            return '';
          }
    ''');
              } else {
                metaCode.writeln('''
            if($typeName == null){
                return null;
            } else if ($typeName.isEmpty) {
            return '';
          }
    ''');
              }
              final map = ogIsPremitiveType
                  ? (fieldType == 'DateTime' ? 'p.toIso8601String()' : 'p')
                  : (isEnum ? 'p.name' : 'p.toMap()');
              metaCode.writeln('''
            final map = $typeName${isNotNull ? '' : '?'}.map((p) => $map).toList();
    ''');
            } else {
              final typeName = isPremitiveType ? alias : fieldName;
              late final String map;
              if (writeFn != null) {
                map = '.$writeFn()';
              } else if (isPremitiveType) {
                map = (fieldType == 'DateTime' ? '.toIso8601String()' : '');
              } else if (field.type.isDartCoreMap) {
                map = '';
              } else {
                map = (isEnum ? '.name' : '.toMap()');
              }

              if (isNotNull) {
                metaCode.writeln('''
            final map = $typeName$map;
    ''');
              } else {
                metaCode.writeln('''
            if($typeName == null){
                return null;
            }
            final map = $typeName$map;
    ''');
              }
            }

            metaCode.writeln('''
            return ${isEnum && !isDartCoreList ? 'map' : 'jsonEncode(map)'};
            },
    ''');
          } else {
            metaCode.writeln('''
          write: (model) => model.$fieldName,
    ''');
          }
          if (jsonEncoded) {
            if (alias != null) {
              if (aliasNotNull) {
                copyWithPropsList.writeln('$jsonEncodedType? $alias,');
                copyWithList.writeln('$alias: $alias ?? this.$alias,');
              } else {
                copyWithPropsList.writeln(
                  'ValueGetter<$jsonEncodedType?>? $alias,',
                );
                copyWithList.writeln(
                  '$alias: $alias != null ? $alias() : this.$alias,',
                );
              }
              if (extraFields.containsKey(alias)) {
                extraFields.remove(alias);
              }
            }
            metaCode.writeln('''
          read: (json, model, value){
    ''');
            if (isDartCoreList) {
              metaCode.writeln('''
            if (value == '') {
            value = '[]';
          }
    ''');
            }
            metaCode.writeln('''
            return model.read$fieldNameCamel(json, value);
          },
        );
    ''');
          } else if (notNull) {
            metaCode.writeln('''
          read: (json, model, value) => model.copyWith(
            $fieldName: value as $fieldType?, 
            json: json,
          ),
        );
    ''');
          } else {
            metaCode.writeln('''
          read: (json, model, value) => model.copyWith(
            $fieldName: ()=>value as $fieldType?, 
            json: json,
          ),
        );
    ''');
          }
          final prefix = isList ? 'List<' : '';
          final suffix = isList ? '>' : '';
          if (notNull) {
            copyWithPropsList.writeln('$prefix$fieldType$suffix? $fieldName,');
            copyWithList.writeln('$fieldName: $fieldName ?? this.$fieldName,');
          } else {
            copyWithPropsList.writeln(
              'ValueGetter<$prefix$fieldType$suffix?>? $fieldName,',
            );
            copyWithList.writeln(
              '$fieldName: $fieldName != null ? '
              '$fieldName() : this.$fieldName,',
            );
          }

          if (extraFields.containsKey(fieldName)) {
            extraFields.remove(fieldName);
          }
        }
      } else if (_nullablePropChecker.hasAnnotationOfExact(field)) {
        final fieldName = field.name;
        final fieldType = field.type.cleanDisplayString;
        final fieldTypeFull = field.type.getDisplayString();
        extraFields[fieldName!] = _ExtraField(
          type: fieldType,
          notNull: false,
          typeFull: fieldTypeFull,
        );
      } else if (_copyablePropChecker.hasAnnotationOfExact(field)) {
        final fieldName = field.name;
        final fieldType = field.type.cleanDisplayString;
        final fieldTypeFull = field.type.getDisplayString();
        extraFields[fieldName!] = _ExtraField(
          type: fieldType,
          notNull: field.type.nullabilitySuffix == NullabilitySuffix.none,
          typeFull: fieldTypeFull,
        );
      }
    }
    for (final fieldName in extraFields.keys) {
      final extraField = extraFields[fieldName]!;

      propsList.writeln('$fieldName,');
      getList.writeln('${extraField.typeFull} get $fieldName;');
      if (extraField.notNull) {
        copyWithPropsList.writeln('${extraField.type}? $fieldName,');
        copyWithList.writeln('$fieldName: $fieldName ?? this.$fieldName,');
      } else {
        copyWithPropsList.writeln(
          'ValueGetter<${extraField.type}?>? $fieldName,',
        );
        copyWithList.writeln(
          '$fieldName: $fieldName != null ? '
          '$fieldName() : this.$fieldName,',
        );
      }
    }
    mixinCode
      ..writeln(getList)
      ..writeln('''

      @override
      List<Object?> get props => [
        ...super.props,
      ''')
      ..writeln('''
      $propsList
      ];''')
      ..writeln('''
      @override
      $className copyWith({
        String? id,
        String? collectionId,
        DateTime? createdAt,
        DateTime? updatedAt,
        $copyWithPropsList
        Map<String, dynamic>? json,
      }){
        return $className(
          id: id ?? this.id,
          collectionId: collectionId ?? this.collectionId,
          createdAt: createdAt ?? this.createdAt,
          updatedAt: updatedAt ?? this.updatedAt,
          $copyWithList
        );
      }''')
      ..writeln('}');

    metaCode
      ..writeln('''
      @override
      Iterable<ColumnDefinition<$className, dynamic>> get columns => [
      id,
      collectionId,
      createdAt,
      updatedAt,
      ''')
      ..writeln('''
      $columnsList
      ];''')
      ..writeln('}');
    mixinCode.write(metaCode.toString());
    await _generateMigrationsFile(buildStep, className!);
    return mixinCode.toString();
  }

  Future<void> _generateMigrationsFile(
    BuildStep buildStep,
    String className,
  ) async {
    final mixinContent =
        '''
part of '${buildStep.inputId.pathSegments.last}';

mixin ${className}Migrations on Model<$className, ${className}Meta> {
  
  @override
  bool createTableAt(int newVersion) {
    return switch (newVersion) {
    /// replace dbVersion with the version number this model was introduced.
    /// remember to update dbVersion to this version
    /// in your OrmContext instance 
    // TODO(dev): replace _dbVersion with number
      _dbVersion => true,
      _ => false,
    };
  }

  @override
  bool recreateTableAt(int newVersion) {
    return switch (newVersion) {
      _ => false,
    };
  }
  @override
  List<ColumnDefinition<$className, dynamic>> addColumnsAt(
    int newVersion,
  ) {
    return switch (newVersion) {
      _ => [],
    };
  }
}''';

    final newFile = File(
      path.join(
        path.current,
        buildStep.inputId.path.replaceAll('.dart', '.migrations.dart'),
      ),
    );
    if (!newFile.existsSync()) {
      await newFile.writeAsString(mixinContent);
    } else {
      try {
        final contents = await newFile.readAsBytes();
        await newFile.writeAsBytes(contents);
      } catch (e) {
        try {
          await newFile.writeAsString(mixinContent);
        } catch (e) {
          // ignore: avoid_print
          print('exception writing migrations file ${newFile.absolute}: $e');
        }
      }
    }
  }

  String _toUpperCamelCase(String input) {
    return input[0].toUpperCase() + input.substring(1);
  }

  String convertClassNameToSnakeCase(String className) {
    final buffer = StringBuffer();
    var isFirstLetter = true;

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

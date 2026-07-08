import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import '../annotations.dart';

class SafeJsonModelGenerator extends GeneratorForAnnotation<SafeJson> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        'SafeJson can only be applied to classes.',
        element: element,
      );
    }

    final className = element.name;
    final generatedClassName = '_\$${className}SafeProvider';

    final isGenericClass = element.typeParameters.isNotEmpty;
    final typeParameters = element.typeParameters;
    final typeParamNames = typeParameters.map((tp) => tp.name).join(', ');
    final typeParamsWithBounds = typeParameters.map((tp) {
      final name = tp.name;
      final bound = tp.bound;
      if (bound != null) {
        return '$name extends ${bound.getDisplayString()}';
      }
      return name;
    }).join(', ');

    final fields =
        element.fields.where((f) => !f.isStatic && !f.isSynthetic).toList();

    final buffer = StringBuffer();

    // Generate provider class
    buffer.writeln(
      isGenericClass
          ? 'class $generatedClassName<$typeParamsWithBounds> implements SafeJsonModelProvider<$className<$typeParamNames>> {'
          : 'class $generatedClassName implements SafeJsonModelProvider<$className> {',
    );

    // fromJson
    buffer.writeln('  @override');
    if (isGenericClass) {
      buffer.writeln(
          '  $className<$typeParamNames> fromJson(Map<String, dynamic> json) {');
    } else {
      buffer.writeln('  $className fromJson(Map<String, dynamic> json) {');
    }
    buffer.writeln('    return $className(');

    for (final field in fields) {
      final safeField = _getSafeField(field);
      final safeIgnoreChecker = TypeChecker.fromUrl(
          'package:safe_json_mapper/src/annotations.dart#SafeIgnore');
      final safeIgnoreFromJsonChecker = TypeChecker.fromUrl(
          'package:safe_json_mapper/src/annotations.dart#SafeIgnoreFromJson');

      final shouldIgnoreFromJson = safeField?.ignore == true ||
          safeIgnoreChecker.hasAnnotationOfExact(field) ||
          safeIgnoreFromJsonChecker.hasAnnotationOfExact(field);

      if (shouldIgnoreFromJson) {
        continue;
      }

      final fieldName = field.name;
      final String jsonKey = (safeField?.name ?? fieldName) as String;
      final path = safeField?.path;
      final aliases = safeField?.aliases;
      final isRequired = safeField?.required ?? false;
      final defaultValue = safeField?.defaultValue;
      final typeNameWithNull = field.type.getDisplayString();
      final typeName = typeNameWithNull.endsWith('?')
          ? typeNameWithNull.substring(0, typeNameWithNull.length - 1)
          : typeNameWithNull;
      final isNullable =
          field.type.nullabilitySuffix == NullabilitySuffix.question;

      buffer.write('      $fieldName: ');

      String? defaultValueAttr;
      if (defaultValue != null) {
        if (defaultValue is String) {
          defaultValueAttr = "'$defaultValue'";
        } else {
          defaultValueAttr = defaultValue.toString();
        }
      }

      String fallbackValue = 'null';
      if (defaultValueAttr != null) {
        fallbackValue = defaultValueAttr;
      } else {
        fallbackValue = _getFallbackForType(typeName) ?? 'null';
      }

      String mappingExpression;
      if (path != null) {
        mappingExpression = _generateMappingExpressionForPath(
          field,
          path,
          safeField,
          isNullable,
          fallbackValue,
          skipFallback: isRequired,
        );
      } else if (aliases != null && aliases.isNotEmpty) {
        mappingExpression = _generateMappingExpressionForAliases(
          field,
          jsonKey,
          aliases,
          safeField,
          isNullable,
          fallbackValue,
          skipFallback: isRequired,
        );
      } else {
        mappingExpression = _generateMappingExpression(
          field,
          jsonKey,
          safeField,
          isNullable,
          fallbackValue,
          skipFallback: isRequired,
        );
      }

      if (isRequired) {
        mappingExpression =
            "SafeJsonMapper.checkRequired($mappingExpression, '$fieldName', '$className', $fallbackValue)";
      }

      buffer.write(mappingExpression);
      buffer.writeln(',');
    }

    buffer.writeln('    );');
    buffer.writeln('  }');

    // toJson
    buffer.writeln('  @override');
    if (isGenericClass) {
      buffer.writeln(
          '  Map<String, dynamic> toJson($className<$typeParamNames> instance) {');
    } else {
      buffer.writeln('  Map<String, dynamic> toJson($className instance) {');
    }
    buffer.writeln('    final result = <String, dynamic>{};');
    for (final field in fields) {
      final safeField = _getSafeField(field);
      final safeIgnoreChecker = TypeChecker.fromUrl(
          'package:safe_json_mapper/src/annotations.dart#SafeIgnore');
      final safeIgnoreToJsonChecker = TypeChecker.fromUrl(
          'package:safe_json_mapper/src/annotations.dart#SafeIgnoreToJson');

      final shouldIgnoreToJson = safeField?.ignore == true ||
          safeIgnoreChecker.hasAnnotationOfExact(field) ||
          safeIgnoreToJsonChecker.hasAnnotationOfExact(field);

      if (shouldIgnoreToJson) {
        continue;
      }

      final fieldName = field.name;
      final jsonKey = safeField?.name ?? fieldName;
      buffer.writeln(
          "    result['$jsonKey'] = SafeJsonMapper.serializeValue(instance.$fieldName);");
    }
    buffer.writeln('    return result;');
    buffer.writeln('  }');

    buffer.writeln('}');

    // Mixin for equality, hashCode, and toString
    if (isGenericClass) {
      buffer.writeln(
          'mixin \$${className}EqualityMixin<$typeParamsWithBounds> {');
    } else {
      buffer.writeln('mixin \$${className}EqualityMixin {');
    }

    // operator ==
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) {');
    buffer.writeln('    if (identical(this, other)) return true;');
    if (isGenericClass) {
      buffer.writeln(
          '    if (other is! $className<$typeParamNames>) return false;');
    } else {
      buffer.writeln('    if (other is! $className) return false;');
    }
    for (final field in fields) {
      final fieldName = field.name;
      buffer.writeln(
          "    if (!SafeJsonMapper.deepEquals($fieldName, other.$fieldName)) { return false; }");
    }
    buffer.writeln('    return true;');
    buffer.writeln('  }');

    // hashCode
    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode {');
    if (fields.isEmpty) {
      buffer.writeln('    return 0;');
    } else {
      buffer.write('    return Object.hash(');
      buffer.writeAll(
          fields.map((f) => 'SafeJsonMapper.deepHash(${f.name})'), ', ');
      buffer.writeln(');');
    }
    buffer.writeln('  }');

    // toString
    buffer.writeln('  @override');
    buffer.writeln('  String toString() {');
    buffer.writeln("    final buffer = StringBuffer('$className(');");
    for (int i = 0; i < fields.length; i++) {
      final field = fields[i];
      final fieldName = field.name;
      if (i > 0) buffer.writeln("    buffer.write(', ');");
      buffer.writeln("    buffer.write('$fieldName: \$$fieldName');");
    }
    buffer.writeln("    buffer.write(')');");
    buffer.writeln('    return buffer.toString();');
    buffer.writeln('  }');

    buffer.writeln('}');

    // Extension for copyWith and toJson
    if (isGenericClass) {
      buffer.writeln(
          'extension \$${className}SafeJsonExtension<$typeParamsWithBounds> on $className<$typeParamNames> {');
    } else {
      buffer
          .writeln('extension \$${className}SafeJsonExtension on $className {');
    }

    // copyWith
    buffer.write('  $className');
    if (isGenericClass) buffer.write('<$typeParamNames>');
    buffer.write(' copyWith({');
    for (final field in fields) {
      final typeNameWithNull = field.type.getDisplayString();
      // Make all parameters optional (nullable)
      final paramType = typeNameWithNull.endsWith('?')
          ? typeNameWithNull
          : '$typeNameWithNull?';
      buffer.writeln('    $paramType ${field.name},');
    }
    buffer.writeln('  }) {');
    buffer.write('    return $className');
    if (isGenericClass) buffer.write('<$typeParamNames>');
    buffer.writeln('(');
    for (final field in fields) {
      // Use this.fieldName if parameter is null
      buffer
          .writeln('      ${field.name}: ${field.name} ?? this.${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');

    // toJson method on the extension
    buffer.writeln('  Map<String, dynamic> toJson() {');
    buffer.write('    return SafeJsonMapper.toJson');
    if (isGenericClass) {
      buffer.write('<$className<$typeParamNames>>');
    } else {
      buffer.write('<$className>');
    }
    buffer.writeln('(this);');
    buffer.writeln('  }');

    buffer.writeln('}');

    // Registration logic
    buffer.writeln('');
    if (isGenericClass) {
      // For generic models, we can't auto-register, so generate a helper that takes type args
      buffer.writeln('void register$className<$typeParamsWithBounds>() {');
      buffer.writeln(
          '  SafeJsonMapper.register<$className<$typeParamNames>>($generatedClassName<$typeParamNames>());');
      buffer.writeln('}');
    } else {
      buffer.writeln('void register$className() {');
      buffer.writeln(
          '  SafeJsonMapper.register<$className>($generatedClassName());');
      buffer.writeln('}');
    }

    return buffer.toString();
  }

  SafeField? _getSafeField(FieldElement field) {
    final checker = TypeChecker.fromUrl(
        'package:safe_json_mapper/src/annotations.dart#SafeField');
    final boolChecker = TypeChecker.fromUrl(
        'package:safe_json_mapper/src/annotations.dart#SafeBool');
    final numChecker = TypeChecker.fromUrl(
        'package:safe_json_mapper/src/annotations.dart#SafeNum');
    final safeDefaultChecker = TypeChecker.fromUrl(
        'package:safe_json_mapper/src/annotations.dart#SafeDefault');
    final safeIgnoreChecker = TypeChecker.fromUrl(
        'package:safe_json_mapper/src/annotations.dart#SafeIgnore');

    dynamic defaultValue;
    bool ignore = false;

    // Check SafeDefault first
    if (safeDefaultChecker.hasAnnotationOfExact(field)) {
      final annot = safeDefaultChecker.firstAnnotationOfExact(field);
      final reader = ConstantReader(annot);
      defaultValue = reader.read('value').isNull
          ? null
          : reader.read('value').literalValue;
    }

    // Check SafeIgnore
    if (safeIgnoreChecker.hasAnnotationOfExact(field)) {
      ignore = true;
    }

    // Check other annotations
    if (boolChecker.hasAnnotationOfExact(field)) {
      final annot = boolChecker.firstAnnotationOfExact(field);
      final reader = ConstantReader(annot);
      final fieldDefault = reader.read('defaultValue').isNull
          ? null
          : reader.read('defaultValue').literalValue as bool?;
      final aliasesList = reader.read('aliases').isNull
          ? null
          : (reader
              .read('aliases')
              .listValue
              .map((e) => e.toStringValue())
              .whereType<String>()
              .toList());
      return SafeBool(
        required: reader.read('required').boolValue,
        defaultValue: defaultValue ?? fieldDefault,
        name:
            reader.read('name').isNull ? null : reader.read('name').stringValue,
        aliases: aliasesList?.isEmpty == true ? null : aliasesList,
        path:
            reader.read('path').isNull ? null : reader.read('path').stringValue,
        ignore: ignore,
        fromInt: reader.read('fromInt').boolValue,
      );
    }

    if (numChecker.hasAnnotationOfExact(field)) {
      final annot = numChecker.firstAnnotationOfExact(field);
      final reader = ConstantReader(annot);
      final fieldDefault = reader.read('defaultValue').isNull
          ? null
          : reader.read('defaultValue').literalValue as num?;
      final aliasesList = reader.read('aliases').isNull
          ? null
          : (reader
              .read('aliases')
              .listValue
              .map((e) => e.toStringValue())
              .whereType<String>()
              .toList());
      return SafeNum(
        required: reader.read('required').boolValue,
        defaultValue: defaultValue ?? fieldDefault,
        name:
            reader.read('name').isNull ? null : reader.read('name').stringValue,
        aliases: aliasesList?.isEmpty == true ? null : aliasesList,
        path:
            reader.read('path').isNull ? null : reader.read('path').stringValue,
        ignore: ignore,
      );
    }

    if (checker.hasAnnotationOfExact(field)) {
      final annot = checker.firstAnnotationOfExact(field);
      final reader = ConstantReader(annot);
      final fieldDefault = reader.read('defaultValue').isNull
          ? null
          : reader.read('defaultValue').literalValue;
      final aliasesList = reader.read('aliases').isNull
          ? null
          : (reader
              .read('aliases')
              .listValue
              .map((e) => e.toStringValue())
              .whereType<String>()
              .toList());
      return SafeField(
        required: reader.read('required').boolValue,
        defaultValue: defaultValue ?? fieldDefault,
        name:
            reader.read('name').isNull ? null : reader.read('name').stringValue,
        aliases: aliasesList?.isEmpty == true ? null : aliasesList,
        path:
            reader.read('path').isNull ? null : reader.read('path').stringValue,
        ignore: ignore,
      );
    }

    if (defaultValue != null || ignore) {
      return SafeField(
        defaultValue: defaultValue,
        ignore: ignore,
      );
    }

    return null;
  }

  String _generateMappingExpression(FieldElement field, String jsonKey,
      SafeField? safeField, bool isNullable, String fallback,
      {bool skipFallback = false}) {
    final type = field.type;
    final typeNameWithNull = type.getDisplayString();
    final typeName = typeNameWithNull.endsWith('?')
        ? typeNameWithNull.substring(0, typeNameWithNull.length - 1)
        : typeNameWithNull;
    final fieldName = field.name;
    final isRequiredParam = skipFallback ? 'true' : 'false';

    // ===== Primitives =====
    if (typeName == 'int') {
      final expr =
          "SafeJsonMapper.toInt(json['$jsonKey'], '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'double') {
      final expr =
          "SafeJsonMapper.toDouble(json['$jsonKey'], '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'num') {
      final expr =
          "SafeJsonMapper.toNum(json['$jsonKey'], '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'String') {
      final expr =
          "SafeJsonMapper.asString(json['$jsonKey'], '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'bool') {
      final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
      final expr =
          "SafeJsonMapper.toBool(json['$jsonKey'], '$fieldName', fromInt: $fromInt, isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'DateTime') {
      final expr =
          "SafeJsonMapper.toDateTime(json['$jsonKey'], '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    }

    // ===== Enum =====
    final typeElement = type.element;
    if (typeElement is EnumElement) {
      final enumTypeName = typeElement.name;
      final expr =
          "SafeJsonMapper.toEnum<$enumTypeName>(json['$jsonKey'], '$fieldName', $enumTypeName.values, isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    }

    // ===== List =====
    if (type.isDartCoreList) {
      final parameterizedType = type as ParameterizedType;
      final typeArguments = parameterizedType.typeArguments;
      final listFallback = (skipFallback || isNullable) ? 'null' : fallback;

      if (typeArguments.isNotEmpty) {
        final elementType = typeArguments.first;
        final elementTypeNameWithNull = elementType.getDisplayString();
        final elementTypeName = elementTypeNameWithNull.endsWith('?')
            ? elementTypeNameWithNull.substring(
                0, elementTypeNameWithNull.length - 1)
            : elementTypeNameWithNull;

        String expr;
        if (elementTypeName == 'int') {
          expr = "SafeJsonMapper.toIntList(json['$jsonKey'], '$fieldName')";
        } else if (elementTypeName == 'double') {
          expr = "SafeJsonMapper.toDoubleList(json['$jsonKey'], '$fieldName')";
        } else if (elementTypeName == 'num') {
          expr = "SafeJsonMapper.toNumList(json['$jsonKey'], '$fieldName')";
        } else if (elementTypeName == 'String') {
          expr = "SafeJsonMapper.toStringList(json['$jsonKey'], '$fieldName')";
        } else if (elementTypeName == 'bool') {
          final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
          expr =
              "SafeJsonMapper.toBoolList(json['$jsonKey'], '$fieldName', fromInt: $fromInt)";
        } else if (elementTypeName == 'DateTime') {
          expr =
              "SafeJsonMapper.toDateTimeList(json['$jsonKey'], '$fieldName')";
        } else {
          final elementTypeElement = elementType.element;
          if (elementTypeElement is EnumElement) {
            final enumTypeName = elementTypeElement.name;
            expr =
                "SafeJsonMapper.toEnumList<$enumTypeName>(json['$jsonKey'], '$fieldName', $enumTypeName.values)";
          } else {
            expr =
                "SafeJsonMapper.toModelList<$elementTypeName>(json['$jsonKey'], '$fieldName')";
          }
        }
        return isNullable || listFallback == 'null'
            ? expr
            : '$expr ?? $listFallback';
      }
      final ensureList =
          "SafeJsonMapper.ensureList(json['$jsonKey'], '$fieldName')";
      return "($ensureList != null) ? List.from($ensureList) : $listFallback";
    }

    // ===== Map =====
    if (type.isDartCoreMap) {
      final parameterizedType = type as ParameterizedType;
      final typeArguments = parameterizedType.typeArguments;
      final mapFallback = (skipFallback || isNullable) ? 'null' : fallback;

      if (typeArguments.length >= 2) {
        final valueType = typeArguments[1];
        final valueTypeNameWithNull = valueType.getDisplayString();
        final valueTypeName = valueTypeNameWithNull.endsWith('?')
            ? valueTypeNameWithNull.substring(
                0, valueTypeNameWithNull.length - 1)
            : valueTypeNameWithNull;

        String expr;
        if (valueTypeName == 'int') {
          expr = "SafeJsonMapper.toIntMap(json['$jsonKey'], '$fieldName')";
        } else if (valueTypeName == 'double') {
          expr = "SafeJsonMapper.toDoubleMap(json['$jsonKey'], '$fieldName')";
        } else if (valueTypeName == 'num') {
          expr = "SafeJsonMapper.toNumMap(json['$jsonKey'], '$fieldName')";
        } else if (valueTypeName == 'String') {
          expr = "SafeJsonMapper.toStringMap(json['$jsonKey'], '$fieldName')";
        } else if (valueTypeName == 'bool') {
          final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
          expr =
              "SafeJsonMapper.toBoolMap(json['$jsonKey'], '$fieldName', fromInt: $fromInt)";
        } else if (valueTypeName == 'DateTime') {
          expr = "SafeJsonMapper.toDateTimeMap(json['$jsonKey'], '$fieldName')";
        } else {
          final valueTypeElement = valueType.element;
          if (valueTypeElement is EnumElement) {
            final enumTypeName = valueTypeElement.name;
            expr =
                "SafeJsonMapper.toEnumMap<$enumTypeName>(json['$jsonKey'], '$fieldName', $enumTypeName.values)";
          } else {
            expr =
                "SafeJsonMapper.toModelMap<$valueTypeName>(json['$jsonKey'], '$fieldName')";
          }
        }
        return isNullable || mapFallback == 'null'
            ? expr
            : '$expr ?? $mapFallback';
      }
      final ensureMap =
          "SafeJsonMapper.ensureMap(json['$jsonKey'], '$fieldName')";
      return '$ensureMap ?? $mapFallback';
    }

    // ===== Nested model =====
    final modelFallback = (skipFallback || isNullable) ? 'null' : fallback;
    return "(json['$jsonKey'] is Map) ? SafeJsonMapper.fromJson<$typeName>(json['$jsonKey']) : $modelFallback";
  }

  String? _getFallbackForType(String typeName) {
    if (typeName.startsWith('List<') || typeName == 'List') return '[]';
    if (typeName.startsWith('Map<') || typeName == 'Map') return '{}';

    switch (typeName) {
      case 'int':
        return '0';
      case 'double':
        return '0.0';
      case 'num':
        return '0';
      case 'String':
        return "''";
      case 'bool':
        return 'false';
      default:
        return null;
    }
  }

  String _generateMappingExpressionForPath(
    FieldElement field,
    String path,
    SafeField? safeField,
    bool isNullable,
    String fallback, {
    bool skipFallback = false,
  }) {
    final type = field.type;
    final typeNameWithNull = type.getDisplayString();
    final typeName = typeNameWithNull.endsWith('?')
        ? typeNameWithNull.substring(0, typeNameWithNull.length - 1)
        : typeNameWithNull;
    final fieldName = field.name;
    final isRequiredParam = skipFallback ? 'true' : 'false';

    // Generate value access: SafeJsonMapper.getNestedValue(json, path)
    final valueAccessor = "SafeJsonMapper.getNestedValue(json, '$path')";

    // ===== Primitives =====
    if (typeName == 'int') {
      final expr =
          "SafeJsonMapper.toInt($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'double') {
      final expr =
          "SafeJsonMapper.toDouble($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'num') {
      final expr =
          "SafeJsonMapper.toNum($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'String') {
      final expr =
          "SafeJsonMapper.asString($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'bool') {
      final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
      final expr =
          "SafeJsonMapper.toBool($valueAccessor, '$fieldName', fromInt: $fromInt, isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'DateTime') {
      final expr =
          "SafeJsonMapper.toDateTime($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    }

    // ===== Enum =====
    final typeElement = type.element;
    if (typeElement is EnumElement) {
      final enumTypeName = typeElement.name;
      final expr =
          "SafeJsonMapper.toEnum<$enumTypeName>($valueAccessor, '$fieldName', $enumTypeName.values, isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    }

    // ===== List =====
    if (type.isDartCoreList) {
      final parameterizedType = type as ParameterizedType;
      final typeArguments = parameterizedType.typeArguments;
      final listFallback = (skipFallback || isNullable) ? 'null' : fallback;

      if (typeArguments.isNotEmpty) {
        final elementType = typeArguments.first;
        final elementTypeNameWithNull = elementType.getDisplayString();
        final elementTypeName = elementTypeNameWithNull.endsWith('?')
            ? elementTypeNameWithNull.substring(
                0, elementTypeNameWithNull.length - 1)
            : elementTypeNameWithNull;

        String expr;
        if (elementTypeName == 'int') {
          expr = "SafeJsonMapper.toIntList($valueAccessor, '$fieldName')";
        } else if (elementTypeName == 'double') {
          expr = "SafeJsonMapper.toDoubleList($valueAccessor, '$fieldName')";
        } else if (elementTypeName == 'num') {
          expr = "SafeJsonMapper.toNumList($valueAccessor, '$fieldName')";
        } else if (elementTypeName == 'String') {
          expr = "SafeJsonMapper.toStringList($valueAccessor, '$fieldName')";
        } else if (elementTypeName == 'bool') {
          final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
          expr =
              "SafeJsonMapper.toBoolList($valueAccessor, '$fieldName', fromInt: $fromInt)";
        } else if (elementTypeName == 'DateTime') {
          expr = "SafeJsonMapper.toDateTimeList($valueAccessor, '$fieldName')";
        } else {
          final elementTypeElement = elementType.element;
          if (elementTypeElement is EnumElement) {
            final enumTypeName = elementTypeElement.name;
            expr =
                "SafeJsonMapper.toEnumList<$enumTypeName>($valueAccessor, '$fieldName', $enumTypeName.values)";
          } else {
            expr =
                "SafeJsonMapper.toModelList<$elementTypeName>($valueAccessor, '$fieldName')";
          }
        }
        return isNullable || listFallback == 'null'
            ? expr
            : '$expr ?? $listFallback';
      }
      final ensureList =
          "SafeJsonMapper.ensureList($valueAccessor, '$fieldName')";
      return "($ensureList != null) ? List.from($ensureList) : $listFallback";
    }

    // ===== Map =====
    if (type.isDartCoreMap) {
      final parameterizedType = type as ParameterizedType;
      final typeArguments = parameterizedType.typeArguments;
      final mapFallback = (skipFallback || isNullable) ? 'null' : fallback;

      if (typeArguments.length >= 2) {
        final valueType = typeArguments[1];
        final valueTypeNameWithNull = valueType.getDisplayString();
        final valueTypeName = valueTypeNameWithNull.endsWith('?')
            ? valueTypeNameWithNull.substring(
                0, valueTypeNameWithNull.length - 1)
            : valueTypeNameWithNull;

        String expr;
        if (valueTypeName == 'int') {
          expr = "SafeJsonMapper.toIntMap($valueAccessor, '$fieldName')";
        } else if (valueTypeName == 'double') {
          expr = "SafeJsonMapper.toDoubleMap($valueAccessor, '$fieldName')";
        } else if (valueTypeName == 'num') {
          expr = "SafeJsonMapper.toNumMap($valueAccessor, '$fieldName')";
        } else if (valueTypeName == 'String') {
          expr = "SafeJsonMapper.toStringMap($valueAccessor, '$fieldName')";
        } else if (valueTypeName == 'bool') {
          final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
          expr =
              "SafeJsonMapper.toBoolMap($valueAccessor, '$fieldName', fromInt: $fromInt)";
        } else if (valueTypeName == 'DateTime') {
          expr = "SafeJsonMapper.toDateTimeMap($valueAccessor, '$fieldName')";
        } else {
          final valueTypeElement = valueType.element;
          if (valueTypeElement is EnumElement) {
            final enumTypeName = valueTypeElement.name;
            expr =
                "SafeJsonMapper.toEnumMap<$enumTypeName>($valueAccessor, '$fieldName', $enumTypeName.values)";
          } else {
            expr =
                "SafeJsonMapper.toModelMap<$valueTypeName>($valueAccessor, '$fieldName')";
          }
        }
        return isNullable || mapFallback == 'null'
            ? expr
            : '$expr ?? $mapFallback';
      }
      final ensureMap =
          "SafeJsonMapper.ensureMap($valueAccessor, '$fieldName')";
      return '$ensureMap ?? $mapFallback';
    }

    // ===== Nested model =====
    final modelFallback = (skipFallback || isNullable) ? 'null' : fallback;
    return "($valueAccessor is Map) ? SafeJsonMapper.fromJson<$typeName>($valueAccessor) : $modelFallback";
  }

  String _generateMappingExpressionForAliases(
    FieldElement field,
    String jsonKey,
    List<String> aliases,
    SafeField? safeField,
    bool isNullable,
    String fallback, {
    bool skipFallback = false,
  }) {
    // Generate code that tries jsonKey, then aliases in order
    final type = field.type;
    final typeNameWithNull = type.getDisplayString();
    final typeName = typeNameWithNull.endsWith('?')
        ? typeNameWithNull.substring(0, typeNameWithNull.length - 1)
        : typeNameWithNull;
    final fieldName = field.name;
    final isRequiredParam = skipFallback ? 'true' : 'false';

    // Generate value access: try jsonKey first, then aliases
    final keys = [jsonKey, ...aliases];
    final valueAccessor = keys.map((key) => "json['$key']").join(' ?? ');

    // ===== Primitives =====
    if (typeName == 'int') {
      final expr =
          "SafeJsonMapper.toInt($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'double') {
      final expr =
          "SafeJsonMapper.toDouble($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'num') {
      final expr =
          "SafeJsonMapper.toNum($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'String') {
      final expr =
          "SafeJsonMapper.asString($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'bool') {
      final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
      final expr =
          "SafeJsonMapper.toBool($valueAccessor, '$fieldName', fromInt: $fromInt, isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'DateTime') {
      final expr =
          "SafeJsonMapper.toDateTime($valueAccessor, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    }

    // ===== Enum =====
    final typeElement = type.element;
    if (typeElement is EnumElement) {
      final enumTypeName = typeElement.name;
      final expr =
          "SafeJsonMapper.toEnum<$enumTypeName>($valueAccessor, '$fieldName', $enumTypeName.values, isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    }

    // ===== List =====
    if (type.isDartCoreList) {
      final parameterizedType = type as ParameterizedType;
      final typeArguments = parameterizedType.typeArguments;
      final listFallback = (skipFallback || isNullable) ? 'null' : fallback;

      if (typeArguments.isNotEmpty) {
        final elementType = typeArguments.first;
        final elementTypeNameWithNull = elementType.getDisplayString();
        final elementTypeName = elementTypeNameWithNull.endsWith('?')
            ? elementTypeNameWithNull.substring(
                0, elementTypeNameWithNull.length - 1)
            : elementTypeNameWithNull;

        String expr;
        if (elementTypeName == 'int') {
          expr = "SafeJsonMapper.toIntList($valueAccessor, '$fieldName')";
        } else if (elementTypeName == 'double') {
          expr = "SafeJsonMapper.toDoubleList($valueAccessor, '$fieldName')";
        } else if (elementTypeName == 'num') {
          expr = "SafeJsonMapper.toNumList($valueAccessor, '$fieldName')";
        } else if (elementTypeName == 'String') {
          expr = "SafeJsonMapper.toStringList($valueAccessor, '$fieldName')";
        } else if (elementTypeName == 'bool') {
          final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
          expr =
              "SafeJsonMapper.toBoolList($valueAccessor, '$fieldName', fromInt: $fromInt)";
        } else if (elementTypeName == 'DateTime') {
          expr = "SafeJsonMapper.toDateTimeList($valueAccessor, '$fieldName')";
        } else {
          final elementTypeElement = elementType.element;
          if (elementTypeElement is EnumElement) {
            final enumTypeName = elementTypeElement.name;
            expr =
                "SafeJsonMapper.toEnumList<$enumTypeName>($valueAccessor, '$fieldName', $enumTypeName.values)";
          } else {
            expr =
                "SafeJsonMapper.toModelList<$elementTypeName>($valueAccessor, '$fieldName')";
          }
        }
        return isNullable || listFallback == 'null'
            ? expr
            : '$expr ?? $listFallback';
      }
      final ensureList =
          "SafeJsonMapper.ensureList($valueAccessor, '$fieldName')";
      return "($ensureList != null) ? List.from($ensureList) : $listFallback";
    }

    // ===== Map =====
    if (type.isDartCoreMap) {
      final parameterizedType = type as ParameterizedType;
      final typeArguments = parameterizedType.typeArguments;
      final mapFallback = (skipFallback || isNullable) ? 'null' : fallback;

      if (typeArguments.length >= 2) {
        final valueType = typeArguments[1];
        final valueTypeNameWithNull = valueType.getDisplayString();
        final valueTypeName = valueTypeNameWithNull.endsWith('?')
            ? valueTypeNameWithNull.substring(
                0, valueTypeNameWithNull.length - 1)
            : valueTypeNameWithNull;

        String expr;
        if (valueTypeName == 'int') {
          expr = "SafeJsonMapper.toIntMap($valueAccessor, '$fieldName')";
        } else if (valueTypeName == 'double') {
          expr = "SafeJsonMapper.toDoubleMap($valueAccessor, '$fieldName')";
        } else if (valueTypeName == 'num') {
          expr = "SafeJsonMapper.toNumMap($valueAccessor, '$fieldName')";
        } else if (valueTypeName == 'String') {
          expr = "SafeJsonMapper.toStringMap($valueAccessor, '$fieldName')";
        } else if (valueTypeName == 'bool') {
          final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
          expr =
              "SafeJsonMapper.toBoolMap($valueAccessor, '$fieldName', fromInt: $fromInt)";
        } else if (valueTypeName == 'DateTime') {
          expr = "SafeJsonMapper.toDateTimeMap($valueAccessor, '$fieldName')";
        } else {
          final valueTypeElement = valueType.element;
          if (valueTypeElement is EnumElement) {
            final enumTypeName = valueTypeElement.name;
            expr =
                "SafeJsonMapper.toEnumMap<$enumTypeName>($valueAccessor, '$fieldName', $enumTypeName.values)";
          } else {
            expr =
                "SafeJsonMapper.toModelMap<$valueTypeName>($valueAccessor, '$fieldName')";
          }
        }
        return isNullable || mapFallback == 'null'
            ? expr
            : '$expr ?? $mapFallback';
      }
      final ensureMap =
          "SafeJsonMapper.ensureMap($valueAccessor, '$fieldName')";
      return '$ensureMap ?? $mapFallback';
    }

    // ===== Nested model =====
    final modelFallback = (skipFallback || isNullable) ? 'null' : fallback;
    return "($valueAccessor is Map) ? SafeJsonMapper.fromJson<$typeName>($valueAccessor) : $modelFallback";
  }
}

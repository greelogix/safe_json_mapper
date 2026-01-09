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

    final fields = element.fields.where((f) => !f.isStatic && !f.isSynthetic);

    final buffer = StringBuffer();

    buffer.writeln(
        'class $generatedClassName implements SafeJsonModelProvider<$className> {');
    buffer.writeln('  @override');
    buffer.writeln('  $className fromJson(Map<String, dynamic> json) {');
    buffer.writeln('    return $className(');

    for (final field in fields) {
      final safeField = _getSafeField(field);
      final fieldName = field.name;
      final jsonKey = safeField?.name ?? fieldName;
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

      String mappingExpression = _generateMappingExpression(
          field, jsonKey!, safeField, isNullable, fallbackValue,
          skipFallback: isRequired);

      if (isRequired) {
        mappingExpression =
            "SafeJsonMapper.checkRequired($mappingExpression, '$fieldName', '$className', $fallbackValue)";
      }

      buffer.write(mappingExpression);
      buffer.writeln(',');
    }

    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');

    // Registration logic
    buffer.writeln('');
    buffer.writeln('void _register$className() {');
    buffer.writeln(
        '  SafeJsonMapper.register<$className>($generatedClassName());');
    buffer.writeln('}');

    return buffer.toString();
  }

  SafeField? _getSafeField(FieldElement field) {
    final checker = TypeChecker.fromUrl(
        'package:safe_json_mapper/src/annotations.dart#SafeField');
    final boolChecker = TypeChecker.fromUrl(
        'package:safe_json_mapper/src/annotations.dart#SafeBool');
    final numChecker = TypeChecker.fromUrl(
        'package:safe_json_mapper/src/annotations.dart#SafeNum');

    if (boolChecker.hasAnnotationOfExact(field)) {
      final annot = boolChecker.firstAnnotationOfExact(field);
      final reader = ConstantReader(annot);
      return SafeBool(
        required: reader.read('required').boolValue,
        defaultValue: reader.read('defaultValue').isNull
            ? null
            : reader.read('defaultValue').literalValue as bool?,
        name:
            reader.read('name').isNull ? null : reader.read('name').stringValue,
        fromInt: reader.read('fromInt').boolValue,
      );
    }

    if (numChecker.hasAnnotationOfExact(field)) {
      final annot = numChecker.firstAnnotationOfExact(field);
      final reader = ConstantReader(annot);
      return SafeNum(
        required: reader.read('required').boolValue,
        defaultValue: reader.read('defaultValue').isNull
            ? null
            : reader.read('defaultValue').literalValue as num?,
        name:
            reader.read('name').isNull ? null : reader.read('name').stringValue,
      );
    }

    if (checker.hasAnnotationOfExact(field)) {
      final annot = checker.firstAnnotationOfExact(field);
      final reader = ConstantReader(annot);
      return SafeField(
        required: reader.read('required').boolValue,
        defaultValue: reader.read('defaultValue').isNull
            ? null
            : reader.read('defaultValue').literalValue,
        name:
            reader.read('name').isNull ? null : reader.read('name').stringValue,
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

    final valueExpr = "json['$jsonKey']";
    final fieldName = field.name;
    final isRequiredParam = skipFallback ? "true" : "false";

    if (typeName == 'int') {
      final expr =
          "SafeJsonMapper.toInt($valueExpr, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'double') {
      final expr =
          "SafeJsonMapper.toDouble($valueExpr, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'num') {
      final expr =
          "SafeJsonMapper.toNum($valueExpr, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'String') {
      final expr =
          "SafeJsonMapper.asString($valueExpr, '$fieldName', isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (typeName == 'bool') {
      final fromInt = (safeField is SafeBool) ? safeField.fromInt : false;
      final expr =
          "SafeJsonMapper.toBool($valueExpr, '$fieldName', fromInt: $fromInt, isRequired: $isRequiredParam)";
      return (skipFallback || isNullable) ? expr : '($expr ?? $fallback)';
    } else if (type.isDartCoreList) {
      final typeArguments = (type as ParameterizedType).typeArguments;
      final listFallback = (skipFallback || isNullable) ? 'null' : fallback;

      // Use ensureList logic to separate check
      final ensureListLogic = "SafeJsonMapper.ensureList($valueExpr, '$fieldName')";

      if (typeArguments.isNotEmpty) {
        final elementType = typeArguments.first;
        final elementTypeNameWithNull = elementType.getDisplayString();
        final elementTypeName = elementTypeNameWithNull.endsWith('?')
            ? elementTypeNameWithNull.substring(
                0, elementTypeNameWithNull.length - 1)
            : elementTypeNameWithNull;

        String elementMapping;
        if (elementTypeName == 'int') {
          elementMapping = "SafeJsonMapper.toInt(e, '$fieldName')";
        } else if (elementTypeName == 'double') {
          elementMapping = "SafeJsonMapper.toDouble(e, '$fieldName')";
        } else if (elementTypeName == 'String') {
          elementMapping = "SafeJsonMapper.asString(e, '$fieldName')";
        } else if (elementTypeName == 'bool') {
          elementMapping = "SafeJsonMapper.toBool(e, '$fieldName')";
        } else {
          elementMapping =
              '(e is Map) ? SafeJsonMapper.fromJson<$elementTypeName>(e) : null';
        }

        return "($ensureListLogic)?.map((e) => $elementMapping).whereType<$elementTypeName>().toList() ?? $listFallback";
      }
      return "($ensureListLogic != null) ? List.from($ensureListLogic) : $listFallback";
    } else if (type.isDartCoreMap) {
      final mapFallback = (skipFallback || isNullable) ? 'null' : fallback;
      final ensureMapLogic = "SafeJsonMapper.ensureMap($valueExpr, '$fieldName')";
      return "$ensureMapLogic ?? $mapFallback";
    } else {
      final modelFallback = (skipFallback || isNullable) ? 'null' : fallback;
      return '($valueExpr is Map) ? SafeJsonMapper.fromJson<$typeName>($valueExpr) : $modelFallback';
    }
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
}

import 'dart:convert';
import 'dart:io';

const _defaultOpenClawRoot = '../contrib/openclaw';

Future<void> main(List<String> args) async {
  final openClawRoot = _resolveOpenClawRoot(args);
  final schemaPath = File('${openClawRoot.path}/dist/protocol.schema.json');

  if (!schemaPath.existsSync()) {
    final result = await Process.run(
      'node',
      const <String>['--import', 'tsx', 'scripts/protocol-gen.ts'],
      workingDirectory: openClawRoot.path,
    );
    if (result.exitCode != 0) {
      stderr.writeln(result.stdout);
      stderr.writeln(result.stderr);
      exitCode = result.exitCode;
      return;
    }
  }

  if (!schemaPath.existsSync()) {
    stderr.writeln('Missing expected schema file: ${schemaPath.path}');
    exitCode = 2;
    return;
  }

  final schemaJson = jsonDecode(schemaPath.readAsStringSync());
  final root = Map<String, Object?>.from(schemaJson as Map);
  final definitions = Map<String, Object?>.from(
    root['definitions'] as Map? ?? const <String, Object?>{},
  );

  final generator = _ProtocolDtoGenerator(definitions);
  final output = File('lib/src/generated_protocol_dtos.dart');
  output.writeAsStringSync(generator.generate());
  stdout.writeln('Wrote ${output.path}');
}

Directory _resolveOpenClawRoot(List<String> args) {
  for (final arg in args) {
    if (arg.startsWith('--openclaw-root=')) {
      return Directory(arg.substring('--openclaw-root='.length));
    }
  }
  final fromEnv = Platform.environment['OPENCLAW_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return Directory(fromEnv);
  }
  return Directory(_defaultOpenClawRoot);
}

class _ProtocolDtoGenerator {
  _ProtocolDtoGenerator(this.definitions);

  final Map<String, Object?> definitions;
  final StringBuffer _buffer = StringBuffer();
  final Set<String> _emittedClasses = <String>{};
  final Map<String, Object?> _inlineDefinitions = <String, Object?>{};

  String generate() {
    _buffer
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
      ..writeln('// ignore_for_file: unused_element')
      ..writeln('//')
      ..writeln('// Regenerate with:')
      ..writeln('// dart run tool/sync_openclaw_protocol_dtos.dart')
      ..writeln()
      ..writeln("import 'package:openclaw_gateway/src/errors.dart';")
      ..writeln("import 'package:openclaw_gateway/src/protocol.dart';")
      ..writeln();

    final names = definitions.keys.toList(growable: false)..sort();
    for (final name in names) {
      final schema = _asSchemaMap(definitions[name], context: name);
      _emitNamedClass(_topLevelClassName(name), schema, sourceName: name);
    }

    _emitHelpers();
    return _buffer.toString();
  }

  void _emitNamedClass(
    String className,
    Map<String, Object?> schema, {
    required String sourceName,
  }) {
    if (_emittedClasses.contains(className)) {
      return;
    }
    _emittedClasses.add(className);

    final properties = _propertiesOf(schema);
    final patternProperties = _patternPropertiesOf(schema);
    final anyOf = _anyOfOf(schema);
    if (properties.isEmpty && patternProperties.isEmpty) {
      _emitRawWrapperClass(
        className,
        sourceName: sourceName,
        objectLike: _isObjectSchema(schema) || anyOf.isNotEmpty,
      );
      return;
    }

    final required = _requiredSetOf(schema);
    final fields = <_FieldSpec>[];
    for (final entry in properties.entries) {
      fields.add(
        _buildField(
          className: className,
          jsonKey: entry.key,
          required: required.contains(entry.key),
          schema:
              _asSchemaMap(entry.value, context: '$sourceName.${entry.key}'),
        ),
      );
    }

    _buffer.writeln('class $className {');
    _buffer.writeln('  const $className({');
    for (final field in fields) {
      final requiredPrefix =
          field.isRequired && !field.dartType.endsWith('?') ? 'required ' : '';
      _buffer.writeln('    ${requiredPrefix}this.${field.name},');
    }
    _buffer.writeln('  });');
    _buffer.writeln();
    _buffer.writeln('  factory $className.fromJson(JsonMap json) {');
    _buffer.writeln('    return $className(');
    for (final field in fields) {
      _buffer.writeln(
        "      ${field.name}: ${field.parseExpression(sourceName)},",
      );
    }
    _buffer.writeln('    );');
    _buffer.writeln('  }');
    _buffer.writeln();
    for (final field in fields) {
      _buffer.writeln('  final ${field.dartType} ${field.name};');
    }
    _buffer.writeln();
    _buffer.writeln('  JsonMap toJson() {');
    _buffer.writeln('    return withoutNulls(<String, Object?>{');
    for (final field in fields) {
      _buffer.writeln(
        "      '${field.jsonKey}': ${field.toJsonExpression(field.name)},",
      );
    }
    _buffer.writeln('    });');
    _buffer.writeln('  }');
    _buffer.writeln('}');
    _buffer.writeln();
  }

  void _emitRawWrapperClass(
    String className, {
    required String sourceName,
    required bool objectLike,
  }) {
    final rawType = objectLike ? 'JsonMap' : 'Object?';
    _buffer.writeln('class $className {');
    _buffer.writeln('  const $className(this.value);');
    _buffer.writeln();
    if (objectLike) {
      _buffer.writeln('  factory $className.fromJson(JsonMap json) {');
      _buffer.writeln('    return $className(json);');
      _buffer.writeln('  }');
    } else {
      _buffer.writeln('  factory $className.fromJson(Object? value) {');
      _buffer.writeln('    return $className(value);');
      _buffer.writeln('  }');
    }
    _buffer.writeln();
    _buffer.writeln('  final $rawType value;');
    _buffer.writeln();
    if (objectLike) {
      _buffer.writeln('  JsonMap toJson() => value;');
    } else {
      _buffer.writeln('  Object? toJson() => value;');
    }
    _buffer.writeln('}');
    _buffer.writeln();
  }

  _FieldSpec _buildField({
    required String className,
    required String jsonKey,
    required bool required,
    required Map<String, Object?> schema,
  }) {
    final nullable = !required || _isNullableSchema(schema);
    final fieldName = _safeIdentifier(_toCamelCase(jsonKey));
    final descriptor = _descriptorForSchema(
      className: className,
      fieldName: jsonKey,
      schema: schema,
      nullable: nullable,
    );
    return _FieldSpec(
      jsonKey: jsonKey,
      name: fieldName,
      dartType: descriptor.dartType,
      isRequired: required,
      parseExpression: (contextName) => descriptor.parseExpression(
        jsonKey: jsonKey,
        contextName: contextName,
        required: required,
      ),
      toJsonExpression: descriptor.toJsonExpression,
    );
  }

  _TypeDescriptor _descriptorForSchema({
    required String className,
    required String fieldName,
    required Map<String, Object?> schema,
    required bool nullable,
  }) {
    final ref = _readString(schema[r'$ref']);
    if (ref != null) {
      final refName = ref.split('/').last;
      final refSchema = _asSchemaMap(definitions[refName], context: refName);
      final refClassName = _topLevelClassName(refName);
      _emitNamedClass(refClassName, refSchema, sourceName: refName);
      return _modelDescriptor(refClassName, nullable: nullable);
    }

    final anyOf = _anyOfOf(schema);
    if (anyOf.isNotEmpty) {
      final nonNullVariants = anyOf.where((entry) => !_isNullSchema(entry));
      final hasNull = anyOf.length != nonNullVariants.length;
      if (nonNullVariants.length == 1) {
        return _descriptorForSchema(
          className: className,
          fieldName: fieldName,
          schema: nonNullVariants.first,
          nullable: nullable || hasNull,
        );
      }
      if (_allStringLike(nonNullVariants)) {
        return _stringDescriptor(
          nullable: nullable || hasNull,
          allowEmpty: !_requiresNonEmptyString(schema),
        );
      }
      return _valueDescriptor(nullable: true);
    }

    final type = _readString(schema['type']);
    switch (type) {
      case 'string':
        return _stringDescriptor(
          nullable: nullable,
          allowEmpty: !_requiresNonEmptyString(schema),
        );
      case 'integer':
        return _intDescriptor(nullable: nullable);
      case 'number':
        return _numDescriptor(nullable: nullable);
      case 'boolean':
        return _boolDescriptor(nullable: nullable);
      case 'array':
        final itemSchema = _asSchemaMap(
          schema['items'],
          context: '$className.$fieldName[]',
        );
        final itemDescriptor = _descriptorForSchema(
          className: className,
          fieldName: '${fieldName}Item',
          schema: itemSchema,
          nullable: false,
        );
        return _listDescriptor(itemDescriptor, nullable: nullable);
      case 'object':
        final properties = _propertiesOf(schema);
        final patternProperties = _patternPropertiesOf(schema);
        if (properties.isNotEmpty) {
          final inlineClassName = _inlineClassName(className, fieldName);
          if (!_inlineDefinitions.containsKey(inlineClassName)) {
            _inlineDefinitions[inlineClassName] = schema;
            _emitNamedClass(
              inlineClassName,
              schema,
              sourceName: '$className.$fieldName',
            );
          }
          return _modelDescriptor(inlineClassName, nullable: nullable);
        }
        if (patternProperties.isNotEmpty) {
          final valueSchema = patternProperties.values.first;
          final patternDescriptor = _descriptorForPatternValue(valueSchema);
          return _mapDescriptor(patternDescriptor, nullable: nullable);
        }
        return _jsonMapDescriptor(nullable: nullable);
    }

    if (schema.containsKey('const')) {
      final constValue = schema['const'];
      if (constValue is String) {
        return _stringDescriptor(
          nullable: nullable,
          allowEmpty: constValue.isEmpty,
        );
      }
      if (constValue is bool) {
        return _boolDescriptor(nullable: nullable);
      }
      if (constValue is int) {
        return _intDescriptor(nullable: nullable);
      }
      if (constValue is num) {
        return _numDescriptor(nullable: nullable);
      }
    }

    return _valueDescriptor(nullable: true);
  }

  _TypeDescriptor _descriptorForPatternValue(Object? rawSchema) {
    final schema = _asSchemaMap(rawSchema, context: 'patternProperties');
    final type = _readString(schema['type']);
    switch (type) {
      case 'string':
        return _stringDescriptor(nullable: false, allowEmpty: true);
      case 'integer':
        return _intDescriptor(nullable: false);
      case 'number':
        return _numDescriptor(nullable: false);
      case 'boolean':
        return _boolDescriptor(nullable: false);
      default:
        return _jsonMapDescriptor(nullable: false);
    }
  }

  _TypeDescriptor _stringDescriptor({
    required bool nullable,
    required bool allowEmpty,
  }) {
    final type = nullable ? 'String?' : 'String';
    return _TypeDescriptor(
      dartType: type,
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        if (required && !nullable) {
          return "_generatedReadRequiredString(json, '$jsonKey', context: '$contextName.$jsonKey', allowEmpty: $allowEmpty)";
        }
        return "_generatedReadNullableString(json['$jsonKey'], allowEmpty: $allowEmpty)";
      },
      toJsonExpression: (valueExpr) => valueExpr,
    );
  }

  _TypeDescriptor _intDescriptor({
    required bool nullable,
  }) {
    return _TypeDescriptor(
      dartType: nullable ? 'int?' : 'int',
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        if (required && !nullable) {
          return "readRequiredInt(json, '$jsonKey', context: '$contextName.$jsonKey')";
        }
        return "readNullableInt(json['$jsonKey'])";
      },
      toJsonExpression: (valueExpr) => valueExpr,
    );
  }

  _TypeDescriptor _numDescriptor({
    required bool nullable,
  }) {
    return _TypeDescriptor(
      dartType: nullable ? 'num?' : 'num',
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        if (required && !nullable) {
          return "_generatedReadRequiredNum(json, '$jsonKey', context: '$contextName.$jsonKey')";
        }
        return "_generatedReadNullableNum(json['$jsonKey'])";
      },
      toJsonExpression: (valueExpr) => valueExpr,
    );
  }

  _TypeDescriptor _boolDescriptor({
    required bool nullable,
  }) {
    return _TypeDescriptor(
      dartType: nullable ? 'bool?' : 'bool',
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        if (required && !nullable) {
          return "readRequiredBool(json, '$jsonKey', context: '$contextName.$jsonKey')";
        }
        return "readNullableBool(json['$jsonKey'])";
      },
      toJsonExpression: (valueExpr) => valueExpr,
    );
  }

  _TypeDescriptor _jsonMapDescriptor({
    required bool nullable,
  }) {
    return _TypeDescriptor(
      dartType: nullable ? 'JsonMap?' : 'JsonMap',
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        if (required && !nullable) {
          return "asJsonMap(_generatedReadRequiredValue(json, '$jsonKey', context: '$contextName'), context: '$contextName.$jsonKey')";
        }
        return "json['$jsonKey'] == null ? null : asJsonMap(json['$jsonKey'], context: '$contextName.$jsonKey')";
      },
      toJsonExpression: (valueExpr) => valueExpr,
    );
  }

  _TypeDescriptor _valueDescriptor({
    required bool nullable,
  }) {
    return _TypeDescriptor(
      dartType: nullable ? 'Object?' : 'Object?',
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        if (required && !nullable) {
          return "_generatedReadRequiredValue(json, '$jsonKey', context: '$contextName')";
        }
        return "json['$jsonKey']";
      },
      toJsonExpression: (valueExpr) => valueExpr,
    );
  }

  _TypeDescriptor _modelDescriptor(
    String className, {
    required bool nullable,
  }) {
    return _TypeDescriptor(
      dartType: nullable ? '$className?' : className,
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        if (required && !nullable) {
          return "$className.fromJson(asJsonMap(_generatedReadRequiredValue(json, '$jsonKey', context: '$contextName'), context: '$contextName.$jsonKey'))";
        }
        return "json['$jsonKey'] == null ? null : $className.fromJson(asJsonMap(json['$jsonKey'], context: '$contextName.$jsonKey'))";
      },
      toJsonExpression: (valueExpr) =>
          '$valueExpr${nullable ? '?' : ''}.toJson()',
    );
  }

  _TypeDescriptor _listDescriptor(
    _TypeDescriptor itemDescriptor, {
    required bool nullable,
  }) {
    final innerType = itemDescriptor.dartType;
    return _TypeDescriptor(
      dartType: nullable ? 'List<$innerType>?' : 'List<$innerType>',
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        final access = "json['$jsonKey']";
        final context = '$contextName.$jsonKey';
        final mapped = _listItemParseExpression(
          descriptor: itemDescriptor,
          itemVar: 'entry',
          contextName: '$context[]',
        );
        final listExpr =
            "asJsonList($access, context: '$context').map((entry) => $mapped).toList(growable: false)";
        if (required && !nullable) {
          return listExpr;
        }
        return "$access == null ? null : $listExpr";
      },
      toJsonExpression: (valueExpr) {
        final itemExpr = _listItemToJsonExpression(
          descriptor: itemDescriptor,
          itemVar: 'entry',
        );
        final listExpr =
            "$valueExpr${nullable ? '?' : ''}.map((entry) => $itemExpr).toList(growable: false)";
        return listExpr;
      },
    );
  }

  _TypeDescriptor _mapDescriptor(
    _TypeDescriptor valueDescriptor, {
    required bool nullable,
  }) {
    final innerType = valueDescriptor.dartType;
    return _TypeDescriptor(
      dartType:
          nullable ? 'Map<String, $innerType>?' : 'Map<String, $innerType>',
      parseExpression: ({
        required String jsonKey,
        required String contextName,
        required bool required,
      }) {
        final access = "json['$jsonKey']";
        final context = '$contextName.$jsonKey';
        final mapped = _mapValueParseExpression(
          descriptor: valueDescriptor,
          valueVar: 'entry.value',
          contextName: '$context.\${entry.key}',
        );
        final mapExpr =
            "Map<String, $innerType>.unmodifiable({for (final entry in asJsonMap($access, context: '$context').entries) entry.key: $mapped})";
        if (required && !nullable) {
          return mapExpr;
        }
        return "$access == null ? null : $mapExpr";
      },
      toJsonExpression: (valueExpr) => valueExpr,
    );
  }

  String _listItemParseExpression({
    required _TypeDescriptor descriptor,
    required String itemVar,
    required String contextName,
  }) {
    final type = descriptor.dartType.replaceAll('?', '');
    if (type == 'String') {
      return "_generatedReadItemString($itemVar, context: '$contextName')";
    }
    if (type == 'int') {
      return "_generatedReadItemInt($itemVar, context: '$contextName')";
    }
    if (type == 'num') {
      return "_generatedReadItemNum($itemVar, context: '$contextName')";
    }
    if (type == 'bool') {
      return "_generatedReadItemBool($itemVar, context: '$contextName')";
    }
    if (type == 'JsonMap') {
      return "asJsonMap($itemVar, context: '$contextName')";
    }
    if (type.startsWith('GatewaySchema')) {
      return "$type.fromJson(asJsonMap($itemVar, context: '$contextName'))";
    }
    return itemVar;
  }

  String _mapValueParseExpression({
    required _TypeDescriptor descriptor,
    required String valueVar,
    required String contextName,
  }) {
    final type = descriptor.dartType.replaceAll('?', '');
    if (type == 'String') {
      return "_generatedReadItemString($valueVar, context: '$contextName')";
    }
    if (type == 'int') {
      return "_generatedReadItemInt($valueVar, context: '$contextName')";
    }
    if (type == 'num') {
      return "_generatedReadItemNum($valueVar, context: '$contextName')";
    }
    if (type == 'bool') {
      return "_generatedReadItemBool($valueVar, context: '$contextName')";
    }
    if (type == 'JsonMap') {
      return "asJsonMap($valueVar, context: '$contextName')";
    }
    if (type.startsWith('GatewaySchema')) {
      return "$type.fromJson(asJsonMap($valueVar, context: '$contextName'))";
    }
    return valueVar;
  }

  String _listItemToJsonExpression({
    required _TypeDescriptor descriptor,
    required String itemVar,
  }) {
    final type = descriptor.dartType.replaceAll('?', '');
    if (type.startsWith('GatewaySchema')) {
      return '$itemVar.toJson()';
    }
    return itemVar;
  }

  void _emitHelpers() {
    _buffer
      ..writeln('String _generatedReadRequiredString(')
      ..writeln('  JsonMap json,')
      ..writeln('  String key, {')
      ..writeln('  required String context,')
      ..writeln('  required bool allowEmpty,')
      ..writeln('}) {')
      ..writeln("  final value = json[key];")
      ..writeln('  if (value is String && (allowEmpty || value.isNotEmpty)) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln(
        "  throw GatewayProtocolException('Missing or invalid \"\$key\" in \$context.');",
      )
      ..writeln('}')
      ..writeln()
      ..writeln('String? _generatedReadNullableString(')
      ..writeln('  Object? value, {')
      ..writeln('  required bool allowEmpty,')
      ..writeln('}) {')
      ..writeln('  if (value is String && (allowEmpty || value.isNotEmpty)) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('Object? _generatedReadRequiredValue(')
      ..writeln('  JsonMap json,')
      ..writeln('  String key, {')
      ..writeln('  required String context,')
      ..writeln('}) {')
      ..writeln("  if (!json.containsKey(key)) {")
      ..writeln(
        "    throw GatewayProtocolException('Missing or invalid \"\$key\" in \$context.');",
      )
      ..writeln('  }')
      ..writeln('  return json[key];')
      ..writeln('}')
      ..writeln()
      ..writeln('num? _generatedReadNullableNum(Object? value) {')
      ..writeln('  if (value is num) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln('  return null;')
      ..writeln('}')
      ..writeln()
      ..writeln('num _generatedReadRequiredNum(')
      ..writeln('  JsonMap json,')
      ..writeln('  String key, {')
      ..writeln('  required String context,')
      ..writeln('}) {')
      ..writeln('  final value = _generatedReadNullableNum(json[key]);')
      ..writeln('  if (value != null) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln(
        "  throw GatewayProtocolException('Missing or invalid \"\$key\" in \$context.');",
      )
      ..writeln('}')
      ..writeln()
      ..writeln('String _generatedReadItemString(')
      ..writeln('  Object? value, {')
      ..writeln('  required String context,')
      ..writeln('}) {')
      ..writeln('  if (value is String) {')
      ..writeln('    return value;')
      ..writeln('  }')
      ..writeln(
          "  throw GatewayProtocolException('Expected string in \$context.');")
      ..writeln('}')
      ..writeln()
      ..writeln('int _generatedReadItemInt(')
      ..writeln('  Object? value, {')
      ..writeln('  required String context,')
      ..writeln('}) {')
      ..writeln('  final intValue = readNullableInt(value);')
      ..writeln('  if (intValue != null) {')
      ..writeln('    return intValue;')
      ..writeln('  }')
      ..writeln(
          "  throw GatewayProtocolException('Expected int in \$context.');")
      ..writeln('}')
      ..writeln()
      ..writeln('num _generatedReadItemNum(')
      ..writeln('  Object? value, {')
      ..writeln('  required String context,')
      ..writeln('}) {')
      ..writeln('  final numValue = _generatedReadNullableNum(value);')
      ..writeln('  if (numValue != null) {')
      ..writeln('    return numValue;')
      ..writeln('  }')
      ..writeln(
          "  throw GatewayProtocolException('Expected num in \$context.');")
      ..writeln('}')
      ..writeln()
      ..writeln('bool _generatedReadItemBool(')
      ..writeln('  Object? value, {')
      ..writeln('  required String context,')
      ..writeln('}) {')
      ..writeln('  final boolValue = readNullableBool(value);')
      ..writeln('  if (boolValue != null) {')
      ..writeln('    return boolValue;')
      ..writeln('  }')
      ..writeln(
          "  throw GatewayProtocolException('Expected bool in \$context.');")
      ..writeln('}')
      ..writeln();
  }

  String _topLevelClassName(String name) => 'GatewaySchema$name';

  String _inlineClassName(String className, String fieldName) =>
      '$className${_pascalCase(fieldName)}';

  bool _isObjectSchema(Map<String, Object?> schema) =>
      _readString(schema['type']) == 'object' ||
      schema.containsKey('properties');

  bool _isNullableSchema(Map<String, Object?> schema) {
    if (_isNullSchema(schema)) {
      return true;
    }
    final anyOf = _anyOfOf(schema);
    return anyOf.any(_isNullSchema);
  }

  bool _isNullSchema(Map<String, Object?> schema) =>
      _readString(schema['type']) == 'null';

  bool _allStringLike(Iterable<Map<String, Object?>> schemas) {
    for (final schema in schemas) {
      final type = _readString(schema['type']);
      if (type == 'string') {
        continue;
      }
      if (schema.containsKey('const') && schema['const'] is String) {
        continue;
      }
      return false;
    }
    return true;
  }

  bool _requiresNonEmptyString(Map<String, Object?> schema) {
    final minLength = schema['minLength'];
    return minLength is num && minLength >= 1;
  }

  Map<String, Object?> _propertiesOf(Map<String, Object?> schema) {
    final properties = schema['properties'];
    if (properties is Map<String, Object?>) {
      return properties;
    }
    if (properties is Map) {
      return Map<String, Object?>.from(properties);
    }
    return const <String, Object?>{};
  }

  Map<String, Object?> _patternPropertiesOf(Map<String, Object?> schema) {
    final properties = schema['patternProperties'];
    if (properties is Map<String, Object?>) {
      return properties;
    }
    if (properties is Map) {
      return Map<String, Object?>.from(properties);
    }
    return const <String, Object?>{};
  }

  List<Map<String, Object?>> _anyOfOf(Map<String, Object?> schema) {
    final anyOf = schema['anyOf'];
    if (anyOf is! List) {
      return const <Map<String, Object?>>[];
    }
    return anyOf
        .map((entry) => _asSchemaMap(entry, context: 'anyOf'))
        .toList(growable: false);
  }

  Set<String> _requiredSetOf(Map<String, Object?> schema) {
    final required = schema['required'];
    if (required is! List) {
      return const <String>{};
    }
    return required.whereType<String>().toSet();
  }

  Map<String, Object?> _asSchemaMap(
    Object? raw, {
    required String context,
  }) {
    if (raw is Map<String, Object?>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, Object?>.from(raw);
    }
    return const <String, Object?>{};
  }

  String? _readString(Object? value) {
    return value is String ? value : null;
  }

  String _toCamelCase(String input) {
    final parts = input
        .split(RegExp(r'[^A-Za-z0-9]+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'value';
    }
    final first = parts.first;
    final rest = parts.skip(1).map(
          (part) => part[0].toUpperCase() + part.substring(1),
        );
    return first[0].toLowerCase() + first.substring(1) + rest.join();
  }

  String _pascalCase(String input) {
    final camel = _toCamelCase(input);
    return camel[0].toUpperCase() + camel.substring(1);
  }

  String _safeIdentifier(String input) {
    const keywords = <String>{
      'switch',
      'case',
      'default',
      'class',
      'final',
      'const',
      'return',
      'for',
      'while',
      'if',
      'else',
      'do',
      'in',
      'with',
      'extension',
      'enum',
      'mixin',
      'implements',
      'import',
      'export',
      'library',
      'part',
      'operator',
      'var',
    };
    if (keywords.contains(input)) {
      return '${input}Value';
    }
    return input;
  }
}

class _FieldSpec {
  const _FieldSpec({
    required this.jsonKey,
    required this.name,
    required this.dartType,
    required this.isRequired,
    required this.parseExpression,
    required this.toJsonExpression,
  });

  final String jsonKey;
  final String name;
  final String dartType;
  final bool isRequired;
  final String Function(String contextName) parseExpression;
  final String Function(String valueExpression) toJsonExpression;
}

class _TypeDescriptor {
  const _TypeDescriptor({
    required this.dartType,
    required this.parseExpression,
    required this.toJsonExpression,
  });

  final String dartType;
  final String Function({
    required String jsonKey,
    required String contextName,
    required bool required,
  }) parseExpression;
  final String Function(String valueExpression) toJsonExpression;
}

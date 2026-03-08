import 'dart:io';

const _defaultOpenClawRoot = '../contrib/openclaw';

void main(List<String> args) {
  final openClawRoot = _resolveOpenClawRoot(args);
  final clientInfoPath = File(
    '${openClawRoot.path}/src/gateway/protocol/client-info.ts',
  );
  final methodsPath = File(
    '${openClawRoot.path}/src/gateway/server-methods-list.ts',
  );
  final protocolSchemasPath = File(
    '${openClawRoot.path}/src/gateway/protocol/schema/protocol-schemas.ts',
  );

  for (final path in <File>[clientInfoPath, methodsPath, protocolSchemasPath]) {
    if (!path.existsSync()) {
      stderr.writeln('Missing expected OpenClaw source file: ${path.path}');
      exitCode = 2;
      return;
    }
  }

  final clientInfoSource = clientInfoPath.readAsStringSync();
  final methodsSource = methodsPath.readAsStringSync();
  final protocolSchemasSource = protocolSchemasPath.readAsStringSync();

  final protocolVersion = _parseProtocolVersion(protocolSchemasSource);
  final clientIds = _parseConstObjectValues(
    clientInfoSource,
    'GATEWAY_CLIENT_IDS',
  );
  final clientModes = _parseConstObjectValues(
    clientInfoSource,
    'GATEWAY_CLIENT_MODES',
  );
  final clientCaps = _parseConstObjectValues(
    clientInfoSource,
    'GATEWAY_CLIENT_CAPS',
  );
  final methods = _parseStringArray(methodsSource, 'BASE_METHODS');
  final events = _parseStringArray(methodsSource, 'GATEWAY_EVENTS');

  final output = File('lib/src/contract.dart');
  output.writeAsStringSync(
    _buildContractLibrary(
      protocolVersion: protocolVersion,
      clientIds: clientIds,
      clientModes: clientModes,
      clientCaps: clientCaps,
      methods: methods,
      events: events,
    ),
  );
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

int _parseProtocolVersion(String source) {
  final match = RegExp(
    r'export const PROTOCOL_VERSION = (\d+) as const;',
  ).firstMatch(source);
  if (match == null) {
    throw StateError('Could not parse PROTOCOL_VERSION.');
  }
  return int.parse(match.group(1)!);
}

List<_NamedValue> _parseConstObjectValues(String source, String name) {
  final match = RegExp(
    'export const $name = \\{([\\s\\S]*?)\\} as const;',
  ).firstMatch(source);
  if (match == null) {
    throw StateError('Could not parse $name.');
  }
  final body = match.group(1)!;
  final values = <_NamedValue>[];
  final entryPattern = RegExp(r'([A-Z0-9_]+): "([^"]+)"');
  for (final entryMatch in entryPattern.allMatches(body)) {
    values.add(
      _NamedValue(
        identifier: _toCamelFromUpperSnake(entryMatch.group(1)!),
        value: entryMatch.group(2)!,
      ),
    );
  }
  if (values.isEmpty) {
    throw StateError('Parsed no values for $name.');
  }
  return values;
}

List<_NamedValue> _parseStringArray(String source, String name) {
  final match = RegExp(
    'const $name = \\[([\\s\\S]*?)\\];',
  ).firstMatch(source);
  if (match == null) {
    throw StateError('Could not parse array $name.');
  }
  final body = match.group(1)!;
  final values = <_NamedValue>[];
  final seen = <String>{};
  final itemPattern = RegExp(r'"([^"]+)"');
  for (final itemMatch in itemPattern.allMatches(body)) {
    final value = itemMatch.group(1)!;
    var identifier = _toCamelFromRuntimeName(value);
    if (!seen.add(identifier)) {
      var suffix = 2;
      while (!seen.add('$identifier$suffix')) {
        suffix += 1;
      }
      identifier = '$identifier$suffix';
    }
    values.add(_NamedValue(identifier: identifier, value: value));
  }
  if (values.isEmpty) {
    throw StateError('Parsed no values for $name.');
  }
  return values;
}

String _buildContractLibrary({
  required int protocolVersion,
  required List<_NamedValue> clientIds,
  required List<_NamedValue> clientModes,
  required List<_NamedValue> clientCaps,
  required List<_NamedValue> methods,
  required List<_NamedValue> events,
}) {
  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln('//')
    ..writeln('// Regenerate with:')
    ..writeln('// dart run tool/sync_openclaw_contract.dart')
    ..writeln()
    ..writeln(
      'const int gatewayContractProtocolVersion = $protocolVersion;',
    )
    ..writeln();

  _writeConstClass(
    buffer,
    className: 'GatewayContractClientIds',
    values: clientIds,
    docComment: 'Allowlisted gateway client ids mirrored from OpenClaw.',
  );
  _writeConstClass(
    buffer,
    className: 'GatewayContractClientModes',
    values: clientModes,
    docComment: 'Allowlisted gateway client modes mirrored from OpenClaw.',
  );
  _writeConstClass(
    buffer,
    className: 'GatewayContractClientCaps',
    values: clientCaps,
    docComment: 'Allowlisted gateway client capability strings.',
  );
  _writeConstClass(
    buffer,
    className: 'GatewayMethodNames',
    values: methods,
    docComment: 'Known base gateway RPC method names mirrored from OpenClaw.',
  );
  _writeConstClass(
    buffer,
    className: 'GatewayEventNames',
    values: events,
    docComment: 'Known gateway event names mirrored from OpenClaw.',
  );
  return buffer.toString();
}

void _writeConstClass(
  StringBuffer buffer, {
  required String className,
  required List<_NamedValue> values,
  required String docComment,
}) {
  buffer.writeln('/// $docComment');
  buffer.writeln('abstract final class $className {');
  for (final entry in values) {
    buffer.writeln(
      "  static const String ${entry.identifier} = '${entry.value}';",
    );
  }
  buffer.writeln();
  buffer.writeln('  static const List<String> values = <String>[');
  for (final entry in values) {
    buffer.writeln('    ${entry.identifier},');
  }
  buffer.writeln('  ];');
  buffer.writeln('}');
  buffer.writeln();
}

String _toCamelFromUpperSnake(String input) {
  final parts = input.toLowerCase().split('_').where((part) => part.isNotEmpty);
  return _toCamelCase(parts);
}

String _toCamelFromRuntimeName(String input) {
  final rawParts = input
      .split(RegExp(r'[^A-Za-z0-9]+'))
      .where((part) => part.isNotEmpty)
      .expand(_splitCamelAware)
      .toList(growable: false);
  return _toCamelCase(rawParts);
}

Iterable<String> _splitCamelAware(String input) {
  final matches = RegExp(
    r'[A-Z]+(?![a-z])|[A-Z]?[a-z0-9]+',
  ).allMatches(input);
  if (matches.isEmpty) {
    return <String>[input.toLowerCase()];
  }
  return matches.map((match) => match.group(0)!.toLowerCase());
}

String _toCamelCase(Iterable<String> parts) {
  final normalized =
      parts.where((part) => part.isNotEmpty).toList(growable: false);
  if (normalized.isEmpty) {
    return 'value';
  }
  final first = normalized.first;
  final rest = normalized.skip(1).map(
        (part) => '${part[0].toUpperCase()}${part.substring(1)}',
      );
  final joined = '$first${rest.join()}';
  if (RegExp(r'^[0-9]').hasMatch(joined)) {
    return 'value$joined';
  }
  return joined;
}

class _NamedValue {
  const _NamedValue({
    required this.identifier,
    required this.value,
  });

  final String identifier;
  final String value;
}

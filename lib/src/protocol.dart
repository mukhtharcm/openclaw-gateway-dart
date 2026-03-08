import 'package:openclaw_gateway/src/errors.dart';

/// JSON object payload used by gateway frames and responses.
typedef JsonMap = Map<String, Object?>;

/// JSON array payload used by gateway frames and responses.
typedef JsonList = List<Object?>;

/// Current OpenClaw gateway protocol version supported by this package.
const int gatewayProtocolVersion = 3;

/// Event name sent by the gateway before the client sends `connect`.
const String gatewayConnectChallengeEvent = 'connect.challenge';

/// Operator role used by UI and admin-style gateway clients.
const String gatewayOperatorRole = 'operator';

/// Node role used by node-host gateway clients.
const String gatewayNodeRole = 'node';

/// Default client role used by operator-style clients.
const String gatewayDefaultRole = gatewayOperatorRole;

/// Default scopes requested by [GatewayConnectOptions.forOperator].
const List<String> defaultOperatorScopes = <String>[
  'operator.admin',
  'operator.read',
  'operator.write',
  'operator.approvals',
  'operator.pairing',
];

/// Converts a decoded JSON value into a [JsonMap].
JsonMap asJsonMap(
  Object? value, {
  required String context,
}) {
  if (value is Map<String, Object?>) {
    return value;
  }
  if (value is Map) {
    return Map<String, Object?>.from(value);
  }
  throw GatewayProtocolException('Expected JSON object for $context.');
}

/// Converts a decoded JSON value into a [JsonList].
JsonList asJsonList(
  Object? value, {
  required String context,
}) {
  if (value is List<Object?>) {
    return value;
  }
  if (value is List) {
    return List<Object?>.from(value);
  }
  throw GatewayProtocolException('Expected JSON array for $context.');
}

/// Removes keys with null values from a JSON object.
JsonMap withoutNulls(Map<String, Object?> value) {
  final out = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.value != null) {
      out[entry.key] = entry.value;
    }
  }
  return out;
}

/// Reads a required non-empty string property from a JSON object.
String readRequiredString(
  JsonMap json,
  String key, {
  required String context,
}) {
  final value = json[key];
  if (value is String && value.isNotEmpty) {
    return value;
  }
  throw GatewayProtocolException('Missing or invalid "$key" in $context.');
}

/// Reads an optional non-empty string value.
String? readNullableString(Object? value) {
  if (value is String && value.isNotEmpty) {
    return value;
  }
  return null;
}

/// Reads a required boolean property from a JSON object.
bool readRequiredBool(
  JsonMap json,
  String key, {
  required String context,
}) {
  final value = json[key];
  if (value is bool) {
    return value;
  }
  throw GatewayProtocolException('Missing or invalid "$key" in $context.');
}

/// Reads a required integer property from a JSON object.
int readRequiredInt(
  JsonMap json,
  String key, {
  required String context,
}) {
  final value = readNullableInt(json[key]);
  if (value != null) {
    return value;
  }
  throw GatewayProtocolException('Missing or invalid "$key" in $context.');
}

/// Reads an optional integer value.
int? readNullableInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

/// Reads a list of strings from a JSON value.
List<String> readStringList(
  Object? value, {
  required String context,
}) {
  final items = asJsonList(value, context: context);
  return items.map((item) {
    if (item is! String) {
      throw GatewayProtocolException('Expected string items in $context.');
    }
    return item;
  }).toList(growable: false);
}

/// Base exception type for gateway client failures.
class GatewayException implements Exception {
  GatewayException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'GatewayException: $message';
}

/// Raised when a gateway frame or payload does not match the expected shape.
class GatewayProtocolException extends GatewayException {
  GatewayProtocolException(super.message, {super.cause});

  @override
  String toString() => 'GatewayProtocolException: $message';
}

/// Raised when the gateway socket closes or errors out.
class GatewayClosedException extends GatewayException {
  GatewayClosedException(super.message, {super.cause});

  @override
  String toString() => 'GatewayClosedException: $message';
}

/// Raised when a gateway operation exceeds its timeout.
class GatewayTimeoutException extends GatewayException {
  GatewayTimeoutException(super.message, {super.cause});

  @override
  String toString() => 'GatewayTimeoutException: $message';
}

/// Raised when the gateway responds with `ok: false`.
class GatewayResponseException extends GatewayException {
  GatewayResponseException({
    required this.code,
    required String message,
    this.details,
    this.retryable,
    this.retryAfterMs,
    Object? cause,
  }) : super(message, cause: cause);

  final String code;
  final Object? details;
  final bool? retryable;
  final int? retryAfterMs;

  @override
  String toString() => 'GatewayResponseException($code): $message';
}

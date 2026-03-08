import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:openclaw_gateway/src/errors.dart';
import 'package:openclaw_gateway/src/protocol.dart';

/// Abstraction used to sign gateway connect payloads for device auth.
abstract interface class GatewayDeviceIdentity {
  String get deviceId;

  /// Raw Ed25519 public key bytes encoded as unpadded base64url.
  String get publicKey;

  Future<String> signPayload(String payload);
}

/// Serializable Ed25519 device identity record.
class GatewayEd25519IdentityData {
  const GatewayEd25519IdentityData({
    required this.deviceId,
    required this.publicKey,
    required this.privateKey,
  });

  factory GatewayEd25519IdentityData.fromJson(JsonMap json) {
    return GatewayEd25519IdentityData(
      deviceId: readRequiredString(
        json,
        'deviceId',
        context: 'GatewayEd25519IdentityData',
      ),
      publicKey: readRequiredString(
        json,
        'publicKey',
        context: 'GatewayEd25519IdentityData',
      ),
      privateKey: readRequiredString(
        json,
        'privateKey',
        context: 'GatewayEd25519IdentityData',
      ),
    );
  }

  final String deviceId;
  final String publicKey;
  final String privateKey;

  JsonMap toJson() {
    return <String, Object?>{
      'deviceId': deviceId,
      'publicKey': publicKey,
      'privateKey': privateKey,
    };
  }
}

/// Ed25519 device identity implementation for OpenClaw gateway auth.
class GatewayEd25519Identity implements GatewayDeviceIdentity {
  GatewayEd25519Identity._({
    required this.deviceId,
    required this.publicKey,
    required SimpleKeyPairData keyPair,
  }) : _keyPair = keyPair;

  factory GatewayEd25519Identity.fromData(GatewayEd25519IdentityData data) {
    final publicKeyBytes = decodeBase64Url(data.publicKey);
    final derivedDeviceId = gatewayDeviceIdFromPublicKeyBytes(publicKeyBytes);
    if (derivedDeviceId != data.deviceId) {
      throw GatewayProtocolException(
        'Invalid device identity data: deviceId does not match public key.',
      );
    }
    return GatewayEd25519Identity._(
      deviceId: data.deviceId,
      publicKey: data.publicKey,
      keyPair: SimpleKeyPairData(
        decodeBase64Url(data.privateKey),
        type: KeyPairType.ed25519,
        publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.ed25519),
      ),
    );
  }

  static Future<GatewayEd25519Identity> generate() async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final keyPairData = await keyPair.extract();
    final publicKey = await keyPair.extractPublicKey();
    final publicKeyBase64Url = encodeBase64Url(publicKey.bytes);
    return GatewayEd25519Identity._(
      deviceId: gatewayDeviceIdFromPublicKeyBytes(publicKey.bytes),
      publicKey: publicKeyBase64Url,
      keyPair: SimpleKeyPairData(
        keyPairData.bytes,
        type: KeyPairType.ed25519,
        publicKey: publicKey,
      ),
    );
  }

  final SimpleKeyPairData _keyPair;

  @override
  final String deviceId;

  @override
  final String publicKey;

  Future<GatewayEd25519IdentityData> exportData() async {
    final keyPairData = await _keyPair.extract();
    return GatewayEd25519IdentityData(
      deviceId: deviceId,
      publicKey: publicKey,
      privateKey: encodeBase64Url(keyPairData.bytes),
    );
  }

  @override
  Future<String> signPayload(String payload) async {
    final algorithm = Ed25519();
    final signature = await algorithm.sign(
      utf8.encode(payload),
      keyPair: _keyPair,
    );
    return encodeBase64Url(signature.bytes);
  }
}

/// Computes the gateway device id for a raw public key.
String gatewayDeviceIdFromPublicKeyBytes(List<int> publicKeyBytes) {
  return crypto.sha256.convert(publicKeyBytes).bytes.toHex();
}

/// Computes the gateway device id for an unpadded base64url public key.
String gatewayDeviceIdFromPublicKey(String publicKeyBase64Url) {
  return gatewayDeviceIdFromPublicKeyBytes(
    decodeBase64Url(publicKeyBase64Url),
  );
}

String encodeBase64Url(List<int> bytes) {
  return base64Url.encode(bytes).replaceAll('=', '');
}

Uint8List decodeBase64Url(String input) {
  final normalized = input.replaceAll('-', '+').replaceAll('_', '/');
  final padded = normalized + '=' * ((4 - (normalized.length % 4)) % 4);
  return Uint8List.fromList(base64.decode(padded));
}

extension on List<int> {
  String toHex() {
    final buffer = StringBuffer();
    for (final byte in this) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }
}

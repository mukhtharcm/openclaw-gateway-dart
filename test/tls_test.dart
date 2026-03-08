import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:test/test.dart';

void main() {
  group('Gateway TLS', () {
    late HttpServer server;
    late Uri uri;

    setUp(() async {
      server = await _startSecureGatewayServer();
      uri = Uri.parse('wss://localhost:${server.port}');
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('rejects a self-signed gateway by default', () async {
      await expectLater(
        GatewayClient.connect(
          uri: uri,
          auth: const GatewayAuth.token('test-token'),
          clientInfo: const GatewayClientInfo(
            id: GatewayClientIds.cli,
            version: '0.1.0',
            platform: 'dart',
            mode: GatewayClientModes.cli,
          ),
        ),
        throwsA(isA<GatewayProtocolException>()),
      );
    });

    test('probes and accepts a pinned TLS fingerprint', () async {
      final fingerprint = await GatewayTlsProbe.probeFingerprint(uri);
      expect(fingerprint, isNotNull);

      final client = await GatewayClient.connect(
        uri: uri,
        auth: const GatewayAuth.token('test-token'),
        tlsPolicy: GatewayTlsPolicy.pinned(fingerprint!),
        clientInfo: const GatewayClientInfo(
          id: GatewayClientIds.cli,
          version: '0.1.0',
          platform: 'dart',
          mode: GatewayClientModes.cli,
        ),
      );
      addTearDown(client.close);

      final health = await client.operator.health();
      expect(health, {'status': 'ok'});
    });

    test('stores and reuses TOFU fingerprints', () async {
      final store = GatewayMemoryTlsFingerprintStore();
      final policy = GatewayTlsPolicy.trustOnFirstUse(
        stableId: 'test-gateway',
        fingerprintStore: store,
      );

      final first = await GatewayClient.connect(
        uri: uri,
        auth: const GatewayAuth.token('test-token'),
        tlsPolicy: policy,
        clientInfo: const GatewayClientInfo(
          id: GatewayClientIds.cli,
          version: '0.1.0',
          platform: 'dart',
          mode: GatewayClientModes.cli,
        ),
      );
      await first.close();

      final stored = await store.readFingerprint(stableId: 'test-gateway');
      expect(stored, isNotNull);

      final second = await GatewayClient.connect(
        uri: uri,
        auth: const GatewayAuth.token('test-token'),
        tlsPolicy: policy,
        clientInfo: const GatewayClientInfo(
          id: GatewayClientIds.cli,
          version: '0.1.0',
          platform: 'dart',
          mode: GatewayClientModes.cli,
        ),
      );
      addTearDown(second.close);

      final health = await second.operator.health();
      expect(health, {'status': 'ok'});
    });

    test('round-trips TLS fingerprints through auth-state storage', () async {
      final store = GatewayJsonAuthStateStore(
        store: GatewayMemoryStringStore(),
      );
      await store.writeFingerprint(
        const GatewayStoredTlsFingerprint(
          stableId: 'gateway-1',
          fingerprint: 'abcd',
          observedAtMs: 1234,
        ),
      );

      final stored = await store.readFingerprint(stableId: 'gateway-1');
      expect(stored?.fingerprint, 'abcd');
      expect(stored?.observedAtMs, 1234);

      await store.deleteFingerprint(stableId: 'gateway-1');
      expect(
        await store.readFingerprint(stableId: 'gateway-1'),
        isNull,
      );
    });
  });
}

Future<HttpServer> _startSecureGatewayServer() async {
  final context = SecurityContext()
    ..useCertificateChainBytes(utf8.encode(_certificatePem))
    ..usePrivateKeyBytes(utf8.encode(_privateKeyPem));
  final server = await HttpServer.bindSecure(
    InternetAddress.loopbackIPv4,
    0,
    context,
  );
  server.listen((HttpRequest request) async {
    final socket = await WebSocketTransformer.upgrade(request);
    socket.add(
      jsonEncode(
        <String, Object?>{
          'type': 'event',
          'event': 'connect.challenge',
          'payload': const <String, Object?>{'nonce': 'nonce-1'},
        },
      ),
    );
    socket.listen((Object? data) {
      final decoded = jsonDecode(data! as String) as Map<String, Object?>;
      if (decoded['type'] != 'req') {
        return;
      }
      final requestId = decoded['id']! as String;
      final method = decoded['method']! as String;
      if (method == 'connect') {
        socket.add(
          jsonEncode(
            <String, Object?>{
              'type': 'res',
              'id': requestId,
              'ok': true,
              'payload': _helloOkPayload(),
            },
          ),
        );
        return;
      }
      if (method == 'health') {
        socket.add(
          jsonEncode(
            <String, Object?>{
              'type': 'res',
              'id': requestId,
              'ok': true,
              'payload': const <String, Object?>{'status': 'ok'},
            },
          ),
        );
        return;
      }
      socket.add(
        jsonEncode(
          <String, Object?>{
            'type': 'res',
            'id': requestId,
            'ok': false,
            'error': const <String, Object?>{
              'code': 'unsupported_method',
              'message': 'unsupported method',
            },
          },
        ),
      );
    });
  });
  return server;
}

Map<String, Object?> _helloOkPayload() {
  return <String, Object?>{
    'type': 'hello-ok',
    'protocol': gatewayProtocolVersion,
    'server': const <String, Object?>{
      'version': 'test',
      'connId': 'tls-conn',
    },
    'features': const <String, Object?>{
      'methods': <String>['health'],
      'events': <String>['chat'],
    },
    'snapshot': const <String, Object?>{
      'presence': <Object?>[],
      'health': <String, Object?>{'status': 'ok'},
      'stateVersion': <String, Object?>{'presence': 1, 'health': 1},
      'uptimeMs': 10,
    },
    'policy': const <String, Object?>{
      'maxPayload': 1000000,
      'maxBufferedBytes': 1000000,
      'tickIntervalMs': 5000,
    },
  };
}

const String _certificatePem = '''
-----BEGIN CERTIFICATE-----
MIIDCTCCAfGgAwIBAgIUcUHDG5JaWEMQUuF4UN/m5lyzg8MwDQYJKoZIhvcNAQEL
BQAwFDESMBAGA1UEAwwJbG9jYWxob3N0MB4XDTI2MDMwODE3NTc0NVoXDTI3MDMw
ODE3NTc0NVowFDESMBAGA1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEAvXUrhA4hvu+QN/Oq6COkh+5xZBsT94+3IO5VdmuR2ZZu
8bbPYiOmZ4HZYvNwLOlbZ6NFjhwPumQ7LZz4wEPK01eYMsWF/sacHg99lGoRf6rI
9c9jpo986iQt2A2ji83xzcvQcbQtLiDTEDFUWoEq7QklZ25fYVwMNqXWR6C1NjK3
IDXI2QmRqL7M8htFnhjajViQnBZSizOM217sBXoYEt3us3rIBwnoxvEBq1ZzAUZP
wzb9QjGdArQUxs4yuU3g4ghV1AmD877X6OrfhNpOLdPcGNGSdxKaAASW8U91hOI5
xq8Gfd+RHwm8PgPZMR6qaZKbIBXIVwDSap6zMbewqQIDAQABo1MwUTAdBgNVHQ4E
FgQUpMZnVPQXzBZS2lSzpNIfIoJisRQwHwYDVR0jBBgwFoAUpMZnVPQXzBZS2lSz
pNIfIoJisRQwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEATJiH
opmLIUN9EpK2adyRUCiwxlBV1AACqdkpaL8BgG+74rfkEojyXxld4AEtHmPNNjzs
KmUNJD125Z/uh8DJ6YOBsMouu2BA6xhrkN8s7KEn5rwhxI/P4ECiAV2Oh5VWiABd
t1lZhyd7MgDHUhiXCU16bSozEtb9xeSwVQJWWy9Ef2owCmEjE1BDmO+HWo0pZyht
LeutsGpGN1cHGZp6dweOfvPn0Qlkv2Ob9zw44HMNb8h8ebNUj9MrpqlbOOn93UjY
nkeZ2JVM8LpxQ09MdQRlPGQnyrL2P03bu4kIW71lhaA+77uQHeX6LwjtIjhgNtYd
/u7W563NFWwBHbcaBw==
-----END CERTIFICATE-----
''';

const String _privateKeyPem = '''
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC9dSuEDiG+75A3
86roI6SH7nFkGxP3j7cg7lV2a5HZlm7xts9iI6Zngdli83As6Vtno0WOHA+6ZDst
nPjAQ8rTV5gyxYX+xpweD32UahF/qsj1z2Omj3zqJC3YDaOLzfHNy9BxtC0uINMQ
MVRagSrtCSVnbl9hXAw2pdZHoLU2MrcgNcjZCZGovszyG0WeGNqNWJCcFlKLM4zb
XuwFehgS3e6zesgHCejG8QGrVnMBRk/DNv1CMZ0CtBTGzjK5TeDiCFXUCYPzvtfo
6t+E2k4t09wY0ZJ3EpoABJbxT3WE4jnGrwZ935EfCbw+A9kxHqppkpsgFchXANJq
nrMxt7CpAgMBAAECggEAVdJ3gW0DZWJRAr+LGnhW5kqhq/bGLz03eB/ur+OfoKDQ
JgepXuwGS9oa1wOuu3GEOejQr8TPbSBNXGbAmhu7i8wgwlMO1XAztTxQJ0R7I8mC
GjO1kPRr4ga8i6P2A3UpxY8/n9o+Iyi0Y5/s9ciQYOrlOjrZ0xkm4TRzYmQO4nsC
bgap68UFAQQYXPIka9/8QMOzn86oire8vKNOycJp4iWKSUtMQTabiXgh8IKODXtj
9teWlUi7P3Eo3+StED8V8vTt9saXkTV6URRvkut8P2GCgoBi42KT/75qW2BiWoQt
yjQYvYo0TG+X7RDRdSPk+2GvFz5ixpPCQsDJUoBz9wKBgQD8aQzPzSnf9G2ymBTO
XmzkjkdRcuKxFPV9aPPxg1kRGBqMV3aZoAgmrimTbQjZuMHJMSdcQzzCvYo0ZmVT
1F3icGQREXy/IB8Ozb3Mtu99Mtbtj/GudpKgwIGawXELVQT3FRM1g/run1HtsFWq
N9+yvz6GLi6yxeSIkJHspyr9BwKBgQDAJu2lXipE6PS9yB34KRRxO2iG59GGvn04
ls/A89UNPDEswmKrSYM2EI4tj1FXNlp+F4wNlqTKZu2ogbdWZQmaXy433vIJSIcm
JBKvbZMTAlQS9FiL+6iFTXpEJ0GqVMi4yfhVrCSTrcVZyBU7/ZoYjlYUDHq9CH9x
eZ3hjzQozwKBgCjaG7+6Ne/QULzaDmwELl2jhXlyPaxpdv4QMYNCPfUdUJasRT7B
/u+7unDo8cjDNWIJuZQeMcRXBvpKJFY4BeXzSM7WZLlOSpiLxg9PAF3kD5Mte/E/
saWg4pkYe+JYpVAUMiK0NLXQRWNR6dt95Y+5kjYHXXmDu+Q6edOyjqubAoGAefR7
IljopQHhy84GT2nrQo69IdpiHo4qNc9qHoHjd9n7L/hT3Xjz4U2Sn5H1w0+JEbxq
NHmnL5syPZ/Ot/O6q5K7Z9SFc6Tnuips/ZCjJw50Q+93f6kC5VAuSLFNuQjEuJvf
lKiEMoK43eniqEemFO3J7kGZaP7KvD+/F9jm9vsCgYBzuwa6flX6ECttzewm8Ng2
TfYDQEysBydUbpT+QRtF2VLa4oJNBiz6ydxAbwHHipZlIlUe5tND1x5OYS2BbvHM
lE5odMzkPBYJyyxuWtpbAoGy1PLmqAeiEhtl3iRLmrhXf6yBd4JtCPPJhtHgSExw
YoU1hOyuqDSpXNNsG+vi8Q==
-----END PRIVATE KEY-----
''';

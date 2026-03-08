import 'dart:io';

import 'package:openclaw_gateway/openclaw_gateway.dart';
import 'package:openclaw_gateway/src/io/discovery_io.dart' as io_impl;
import 'package:test/test.dart';

void main() {
  group('Gateway discovery', () {
    test('parses TXT hints and candidate URIs', () {
      final gateway = GatewayDiscoveredGateway(
        instanceName: 'OpenClaw.local',
        targetHost: 'gateway.local',
        port: 18789,
        txt: const <String, String>{
          'displayName': 'OpenClaw',
          'tailnetDns': 'gateway.tail.ts.net',
          'gatewayTls': '1',
          'gatewayTlsSha256': 'SHA-256:AA:BB',
        },
        ipv4: <InternetAddress>[
          InternetAddress('192.168.1.25'),
        ],
      );

      expect(gateway.displayName, 'OpenClaw');
      expect(gateway.tlsEnabled, isTrue);
      expect(gateway.stableId, 'gateway.tail.ts.net');
      expect(
        gateway.primaryUri,
        Uri.parse('wss://gateway.local:18789/'),
      );

      final policy = gateway.buildTlsPolicy();
      expect(policy.expectedFingerprint, 'SHA-256:AA:BB');
      expect(policy.stableId, 'gateway.tail.ts.net');
    });

    test('resolves PTR, SRV, TXT, and IP records into gateways', () async {
      final client = io_impl.GatewayMdnsDiscoveryClient(
        recordLookup: _FakeMdnsRecordLookup(
          ptrRecords: const <String>[
            'alpha._openclaw-gw._tcp.local',
            'alpha._openclaw-gw._tcp.local',
            'beta._openclaw-gw._tcp.local',
          ],
          srvRecords: const <String, io_impl.GatewayMdnsServiceRecord>{
            'alpha._openclaw-gw._tcp.local': io_impl.GatewayMdnsServiceRecord(
              target: 'alpha.local.',
              port: 18789,
            ),
            'beta._openclaw-gw._tcp.local': io_impl.GatewayMdnsServiceRecord(
              target: 'beta.local.',
              port: 28443,
            ),
          },
          txtRecords: const <String, Map<String, String>>{
            'alpha._openclaw-gw._tcp.local': <String, String>{
              'displayName': 'Alpha',
              'gatewayTls': '0',
            },
            'beta._openclaw-gw._tcp.local': <String, String>{
              'displayName': 'Beta',
              'gatewayTls': '1',
              'tailnetDns': 'beta.tail.ts.net',
            },
          },
          ipv4Records: <String, List<InternetAddress>>{
            'alpha.local.': <InternetAddress>[InternetAddress('10.0.0.10')],
            'beta.local.': <InternetAddress>[InternetAddress('10.0.0.11')],
          },
          ipv6Records: <String, List<InternetAddress>>{
            'beta.local.': <InternetAddress>[InternetAddress('fe80::1')],
          },
        ),
      );

      final discovered = await client.discoverOnce();

      expect(discovered, hasLength(2));
      expect(discovered.first.displayName, 'Alpha');
      expect(discovered.last.displayName, 'Beta');
      expect(
        discovered.first.primaryUri,
        Uri.parse('ws://alpha.local:18789/'),
      );
      expect(
        discovered.last.primaryUri,
        Uri.parse('wss://beta.local:28443/'),
      );
    });
  });
}

class _FakeMdnsRecordLookup implements io_impl.GatewayMdnsRecordLookup {
  _FakeMdnsRecordLookup({
    this.ptrRecords = const <String>[],
    this.srvRecords = const <String, io_impl.GatewayMdnsServiceRecord>{},
    this.txtRecords = const <String, Map<String, String>>{},
    this.ipv4Records = const <String, List<InternetAddress>>{},
    this.ipv6Records = const <String, List<InternetAddress>>{},
  });

  final List<String> ptrRecords;
  final Map<String, io_impl.GatewayMdnsServiceRecord> srvRecords;
  final Map<String, Map<String, String>> txtRecords;
  final Map<String, List<InternetAddress>> ipv4Records;
  final Map<String, List<InternetAddress>> ipv6Records;

  @override
  Future<List<InternetAddress>> lookupIPv4(
    String hostName, {
    required Duration timeout,
  }) async {
    return ipv4Records[hostName] ?? const <InternetAddress>[];
  }

  @override
  Future<List<InternetAddress>> lookupIPv6(
    String hostName, {
    required Duration timeout,
  }) async {
    return ipv6Records[hostName] ?? const <InternetAddress>[];
  }

  @override
  Future<List<String>> lookupPtr(
    String serviceName, {
    required Duration timeout,
  }) async {
    return ptrRecords;
  }

  @override
  Future<io_impl.GatewayMdnsServiceRecord?> lookupSrv(
    String serviceName, {
    required Duration timeout,
  }) async {
    return srvRecords[serviceName];
  }

  @override
  Future<Map<String, String>> lookupTxt(
    String serviceName, {
    required Duration timeout,
  }) async {
    return txtRecords[serviceName] ?? const <String, String>{};
  }
}

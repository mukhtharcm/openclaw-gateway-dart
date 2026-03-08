import 'dart:async';
import 'dart:io';

import 'package:multicast_dns/multicast_dns.dart';
import 'package:openclaw_gateway/src/discovery_models.dart';

/// Bonjour/mDNS discovery for OpenClaw gateways on `dart:io` platforms.
class GatewayMdnsDiscoveryClient implements GatewayDiscoveryClient {
  GatewayMdnsDiscoveryClient({
    GatewayMdnsRecordLookup? recordLookup,
  }) : _recordLookup = recordLookup ?? GatewayMdnsClientRecordLookup();

  final GatewayMdnsRecordLookup _recordLookup;

  @override
  Future<List<GatewayDiscoveredGateway>> discoverOnce({
    GatewayDiscoveryOptions options = const GatewayDiscoveryOptions(),
  }) async {
    final instances = await _recordLookup.lookupPtr(
      options.normalizedServiceName,
      timeout: options.timeout,
    );
    final results = <GatewayDiscoveredGateway>[];
    final seen = <String>{};
    for (final instanceName in instances) {
      final service = await _recordLookup.lookupSrv(
        instanceName,
        timeout: options.timeout,
      );
      if (service == null) {
        continue;
      }
      final txt = await _recordLookup.lookupTxt(
        instanceName,
        timeout: options.timeout,
      );
      final ipv4 = await _recordLookup.lookupIPv4(
        service.target,
        timeout: options.timeout,
      );
      final ipv6 = await _recordLookup.lookupIPv6(
        service.target,
        timeout: options.timeout,
      );
      final dedupeKey = '$instanceName|${service.target}|${service.port}';
      if (!seen.add(dedupeKey)) {
        continue;
      }
      results.add(
        GatewayDiscoveredGateway(
          instanceName: _trimTrailingDot(instanceName),
          targetHost: _trimTrailingDot(service.target),
          port: service.port,
          txt: txt,
          ipv4: ipv4,
          ipv6: ipv6,
        ),
      );
    }
    results.sort(
      (left, right) => left.displayName.toLowerCase().compareTo(
            right.displayName.toLowerCase(),
          ),
    );
    return results;
  }

  @override
  Stream<List<GatewayDiscoveredGateway>> watch({
    GatewayDiscoveryOptions options = const GatewayDiscoveryOptions(),
  }) async* {
    while (true) {
      yield await discoverOnce(options: options);
      await Future<void>.delayed(options.pollInterval);
    }
  }
}

class GatewayMdnsServiceRecord {
  const GatewayMdnsServiceRecord({
    required this.target,
    required this.port,
  });

  final String target;
  final int port;
}

abstract interface class GatewayMdnsRecordLookup {
  Future<List<String>> lookupPtr(
    String serviceName, {
    required Duration timeout,
  });

  Future<GatewayMdnsServiceRecord?> lookupSrv(
    String serviceName, {
    required Duration timeout,
  });

  Future<Map<String, String>> lookupTxt(
    String serviceName, {
    required Duration timeout,
  });

  Future<List<InternetAddress>> lookupIPv4(
    String hostName, {
    required Duration timeout,
  });

  Future<List<InternetAddress>> lookupIPv6(
    String hostName, {
    required Duration timeout,
  });
}

class GatewayMdnsClientRecordLookup implements GatewayMdnsRecordLookup {
  GatewayMdnsClientRecordLookup();

  @override
  Future<List<InternetAddress>> lookupIPv4(
    String hostName, {
    required Duration timeout,
  }) {
    return _withClient(
      (client) async {
        final addresses = await client
            .lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv4(_trimTrailingDot(hostName)),
              timeout: timeout,
            )
            .map((record) => record.address)
            .toList();
        return _uniqueAddresses(addresses);
      },
    );
  }

  @override
  Future<List<InternetAddress>> lookupIPv6(
    String hostName, {
    required Duration timeout,
  }) {
    return _withClient(
      (client) async {
        final addresses = await client
            .lookup<IPAddressResourceRecord>(
              ResourceRecordQuery.addressIPv6(_trimTrailingDot(hostName)),
              timeout: timeout,
            )
            .map((record) => record.address)
            .toList();
        return _uniqueAddresses(addresses);
      },
    );
  }

  @override
  Future<List<String>> lookupPtr(
    String serviceName, {
    required Duration timeout,
  }) {
    return _withClient(
      (client) async {
        final instances = await client
            .lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(serviceName),
              timeout: timeout,
            )
            .map((record) => record.domainName)
            .toList();
        return instances.toSet().toList(growable: false);
      },
    );
  }

  @override
  Future<GatewayMdnsServiceRecord?> lookupSrv(
    String serviceName, {
    required Duration timeout,
  }) {
    return _withClient(
      (client) async {
        final records = await client
            .lookup<SrvResourceRecord>(
              ResourceRecordQuery.service(serviceName),
              timeout: timeout,
            )
            .toList();
        if (records.isEmpty) {
          return null;
        }
        final record = records.first;
        return GatewayMdnsServiceRecord(
          target: record.target,
          port: record.port,
        );
      },
    );
  }

  @override
  Future<Map<String, String>> lookupTxt(
    String serviceName, {
    required Duration timeout,
  }) {
    return _withClient(
      (client) async {
        final records = await client
            .lookup<TxtResourceRecord>(
              ResourceRecordQuery.text(serviceName),
              timeout: timeout,
            )
            .toList();
        final values = <String, String>{};
        for (final record in records) {
          for (final line in record.text.split('\n')) {
            final entry = line.trim();
            if (entry.isEmpty) {
              continue;
            }
            final idx = entry.indexOf('=');
            if (idx <= 0) {
              continue;
            }
            values[entry.substring(0, idx)] = entry.substring(idx + 1);
          }
        }
        return values;
      },
    );
  }

  Future<T> _withClient<T>(
    Future<T> Function(MDnsClient client) action,
  ) async {
    final client = MDnsClient();
    await client.start();
    try {
      return await action(client);
    } finally {
      client.stop();
    }
  }
}

List<InternetAddress> _uniqueAddresses(List<InternetAddress> addresses) {
  final seen = <String>{};
  final results = <InternetAddress>[];
  for (final address in addresses) {
    if (seen.add(address.address)) {
      results.add(address);
    }
  }
  return results;
}

String _trimTrailingDot(String value) {
  if (value.endsWith('.')) {
    return value.substring(0, value.length - 1);
  }
  return value;
}

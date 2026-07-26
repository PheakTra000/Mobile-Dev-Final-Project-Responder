import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

import '../data/local_storage.dart';
import '../models/audit_session.dart';
import '../models/device_with_ports.dart';
import '../models/network_device.dart';
import '../models/exposed_port.dart';

const _quickPorts = [21, 22, 23, 25, 53, 80, 110, 143, 443, 993, 995, 3389, 8080, 8443];

const _deepPorts = [
  // Well-known (0-1023) — IANA assigned
  1, 5, 7, 9, 11, 13, 17, 18, 19, 20, 21, 22, 23, 24, 25, 37, 42, 43, 49,
  50, 53, 67, 68, 69, 70, 79, 80, 88, 95, 106, 109, 110, 111, 113, 119,
  123, 135, 137, 138, 139, 143, 161, 162, 179, 194, 389, 427, 443, 445,
  464, 465, 500, 514, 543, 544, 548, 554, 563, 587, 623, 631, 636, 646,
  873, 902, 989, 990, 993, 995,
  // Registered (1024-49151) — common services
  1080, 1099, 1194, 1433, 1434, 1521, 1701, 1720, 1723, 1755, 1883, 1900,
  1935, 2049, 2181, 2222, 2375, 2376, 2525, 3000, 3001, 3260, 3268, 3269,
  3306, 3389, 4443, 4500, 5000, 5001, 5060, 5061, 5353, 5357, 5432, 5555,
  5601, 5631, 5672, 5683, 5800, 5900, 5901, 5984, 5985, 5986, 6000, 6001,
  61613, 61614, 6379, 6443, 7000, 7001, 7002, 7070, 7100, 7443, 7500,
  8000, 8001, 8008, 8009, 8080, 8081, 8082, 8083, 8084, 8085, 8086, 8087,
  8088, 8089, 8090, 8096, 8443, 8883, 8888, 8920, 8983, 8984, 9000, 9001,
  9042, 9090, 9091, 9099, 9100, 9115, 9200, 9300, 9418, 9443, 9999, 10000,
  10250, 10255, 10443, 11211, 12345, 15000, 19132, 19888, 20000, 2379,
  2380, 25565, 25575, 27015, 27016, 27017, 27018, 28017, 30000, 32400,
  50000, 50070, 60000,
];

const _serviceMap = {
  // Well-known (0-1023)
  1: 'TCPMUX', 5: 'RJE', 7: 'Echo', 9: 'Discard', 11: 'Sysstat',
  13: 'Daytime', 17: 'QOTD', 18: 'MSP', 19: 'Chargen', 20: 'FTP-Data',
  21: 'FTP', 22: 'SSH', 23: 'Telnet', 24: 'Private Mail', 25: 'SMTP',
  37: 'Time', 42: 'Nameserver', 43: 'WHOIS', 49: 'TACACS', 50: 'Re-mail-CK',
  53: 'DNS', 67: 'DHCP-Server', 68: 'DHCP-Client', 69: 'TFTP', 70: 'Gopher',
  79: 'Finger', 80: 'HTTP', 88: 'Kerberos', 95: 'SUPDUP', 106: 'POP3Plus',
  109: 'POP2', 110: 'POP3', 111: 'RPCBind', 113: 'Ident', 119: 'NNTP',
  123: 'NTP', 135: 'MSRPC', 137: 'NetBIOS-NS', 138: 'NetBIOS-DGM',
  139: 'NetBIOS-SSN', 143: 'IMAP', 161: 'SNMP', 162: 'SNMP-Trap',
  179: 'BGP', 194: 'IRC', 389: 'LDAP', 427: 'SLP', 443: 'HTTPS',
  445: 'SMB', 464: 'Kerberos-Change', 465: 'SMTPS', 500: 'IKE',
  514: 'Syslog', 543: 'Klogin', 544: 'Kshell', 548: 'AFP', 554: 'RTSP',
  563: 'NNTPS', 587: 'Submission', 623: 'IPMI', 631: 'IPP', 636: 'LDAPS',
  646: 'LDP', 873: 'Rsync', 902: 'VMware', 989: 'FTPS-Data', 990: 'FTPS',
  993: 'IMAPS', 995: 'POP3S',
  // Registered — common services
  1080: 'SOCKS', 1099: 'RMI-Registry', 1194: 'OpenVPN', 1433: 'MSSQL',
  1434: 'MSSQL-Browser', 1521: 'Oracle', 1701: 'L2TP', 1720: 'H.323',
  1723: 'PPTP', 1755: 'MMS', 1883: 'MQTT', 1900: 'SSDP', 1935: 'RTMP',
  2049: 'NFS', 2181: 'ZooKeeper', 2222: 'SSH-Alt', 2375: 'Docker',
  2376: 'Docker-TLS', 2525: 'SMTP-Alt', 3000: 'Dev-UI', 3001: 'Dev-UI-1',
  3260: 'iSCSI', 3268: 'LDAP-GC', 3269: 'LDAP-GC-SSL', 3306: 'MySQL',
  3389: 'RDP', 4443: 'HTTPS-Alt', 4500: 'NAT-T', 5000: 'UPnP/Flask',
  5001: 'Docker-Secure', 5060: 'SIP', 5061: 'SIPS', 5353: 'mDNS',
  5357: 'WSDAPI', 5432: 'PostgreSQL', 5555: 'ADB', 5601: 'Kibana',
  5631: 'PCAnywhere', 5672: 'AMQP', 5683: 'CoAP', 5800: 'VNC-Web',
  5900: 'VNC', 5901: 'VNC-1', 5984: 'CouchDB', 5985: 'WinRM',
  5986: 'WinRM-TLS', 6000: 'X11', 6001: 'X11-1', 61613: 'STOMP',
  61614: 'STOMPS', 6379: 'Redis', 6443: 'Kubernetes-API', 7000: 'Cassandra',
  7001: 'WebLogic', 7002: 'WebLogic-S', 7070: 'RealServer', 7100: 'XFS',
  7443: 'HTTPS-Alt', 7500: 'Memcache-Alt', 8000: 'HTTP-Alt', 8001: 'HTTP-Alt-1',
  8008: 'HTTP-Proxy', 8009: 'AJP', 8080: 'HTTP-Proxy', 8081: 'HTTP-Proxy-1',
  8082: 'HTTP-Proxy-2', 8083: 'HTTP-Proxy-3', 8084: 'HTTPS-Proxy',
  8085: 'HTTP-Proxy-5', 8086: 'InfluxDB', 8087: 'HTTP-Proxy-7',
  8088: 'HTTP-Proxy-8', 8089: 'Splunk', 8090: 'HTTP-Proxy-10',
  8096: 'Jellyfin', 8443: 'HTTPS-Alt', 8883: 'MQTTS', 8888: 'HTTP-Proxy',
  8920: 'ES-Secure', 8983: 'Solr', 8984: 'Solr-Secure', 9000: 'SonarQube',
  9001: 'PHP-FPM', 9042: 'Cassandra', 9090: 'Prometheus', 9091: 'Transmission',
  9099: 'K8s-Dashboard', 9100: 'Node-Exporter', 9115: 'Redis-Exporter',
  9200: 'Elasticsearch', 9300: 'ES-Transport', 9418: 'Git', 9443: 'K8s-Dashboard-S',
  9999: 'Nagios', 10000: 'Webmin', 10250: 'Kubelet-API', 10255: 'Kubelet-RO',
  10443: 'HTTPS-Alt-2', 11211: 'Memcached', 12345: 'NetBus',
  15000: 'Webmin-1', 19132: 'MCPE', 19888: 'ES-Debug', 20000: 'VoIP',
  2379: 'etcd', 2380: 'etcd-Peer', 25565: 'Minecraft', 25575: 'Minecraft-RCON',
  27015: 'Source-Engine', 27016: 'Steam', 27017: 'MongoDB', 27018: 'MongoDB-S',
  28017: 'MongoDB-Web', 30000: 'Horizon', 32400: 'Plex', 50000: 'SAP',
  50070: 'HDFS', 60000: 'Fortinet',
};

const _highRisk = {21, 23, 135, 139, 445, 1433, 2375, 2376, 3389, 5900, 5985, 5986};
const _mediumRisk = {
  22, 25, 110, 143, 389, 465, 587, 993, 995, 1080, 1194, 1521, 1723,
  1883, 2049, 3306, 4443, 5060, 5432, 5672, 5901, 6379, 6443, 8080,
  8443, 8888, 9090, 9200, 9300, 11211, 27017, 27018, 50000,
};

abstract class ScanRepository {
  Future<String> detectSubnet();
  Future<List<NetworkDevice>> discoverDevices(String subnet,
      {void Function(double progress)? onProgress});
  Future<List<ExposedPort>> checkPorts(NetworkDevice device, ScanType scanType);
  Future<AuditSession> runScan(String profileName, ScanType type);
  Future<List<AuditSession>> getHistory();
}

class ScanRepositoryImpl implements ScanRepository {
  Future<int> _readSubnetMask(String wifiIp) async {
    try {
      final file = File('/proc/net/route');
      final lines = await file.readAsLines();
      int bestPrefix = 0;
      final wifiInt = _ipToInt(wifiIp);
      for (final line in lines) {
        final parts = line.split('\t');
        if (parts.length < 8) continue;
        final destHex = int.parse(parts[1], radix: 16);
        final maskHex = int.parse(parts[7], radix: 16);
        if (maskHex == 0) continue;
        if ((wifiInt & maskHex) == (destHex & maskHex)) {
          int prefix = 0;
          int m = maskHex;
          while (m != 0 && (m & 1) == 1) {
            prefix++;
            m >>= 1;
          }
          if (prefix > bestPrefix) bestPrefix = prefix;
        }
      }
      if (bestPrefix > 0) return bestPrefix;
    } catch (_) {}
    return 24;
  }

  String _computeNetwork(String ip, int prefix) {
    final ipBytes = ip.split('.').map(int.parse).toList();
    final maskInt = prefix == 0 ? 0 : (~0 << (32 - prefix)) & 0xFFFFFFFF;
    final networkBytes = [
      ipBytes[0] & ((maskInt >> 24) & 0xFF),
      ipBytes[1] & ((maskInt >> 16) & 0xFF),
      ipBytes[2] & ((maskInt >> 8) & 0xFF),
      ipBytes[3] & (maskInt & 0xFF),
    ];
    return '${networkBytes[0]}.${networkBytes[1]}.${networkBytes[2]}.${networkBytes[3]}/$prefix';
  }

  int _ipToInt(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
  }

  String _intToIp(int ip) {
    return '${(ip >> 24) & 0xFF}.${(ip >> 16) & 0xFF}.${(ip >> 8) & 0xFF}.${ip & 0xFF}';
  }

  @override
  Future<String> detectSubnet() async {
    try {
      final info = NetworkInfo();
      final wifiIp = await info.getWifiIP();
      if (wifiIp != null) {
        final prefix = await _readSubnetMask(wifiIp);
        return _computeNetwork(wifiIp, prefix);
      }
    } catch (_) {}
    return '192.168.1.0/24';
  }

  @override
  Future<List<NetworkDevice>> discoverDevices(
    String subnet, {
    void Function(double progress)? onProgress,
  }) async {
    final cidrParts = subnet.split('/');
    final prefixLen = int.parse(cidrParts[1]);
    final ipParts = cidrParts[0].split('.').map(int.parse).toList();
    final hostBits = 32 - prefixLen;
    final hostCount = (1 << hostBits) - 2;
    final maxScan = hostCount.clamp(1, 256);

    final prefixIp = ipParts.join('.');
    final devices = <NetworkDevice>[];
    const batchSize = 20;

    for (var start = 1; start <= maxScan; start += batchSize) {
      final end = (start + batchSize - 1).clamp(1, maxScan);
      final futures = <Future<NetworkDevice?>>[];
      for (var i = start; i <= end; i++) {
        final ip = _intToIp(_ipToInt(prefixIp) + i);
        futures.add(_pingHost(ip));
      }
      final results = await Future.wait(futures);
      for (final device in results) {
        if (device != null) devices.add(device);
      }
      onProgress?.call((end / maxScan).clamp(0.0, 1.0));
    }
    return devices;
  }

  Future<NetworkDevice?> _pingHost(String ip) async {
    try {
      final socket = await Socket.connect(ip, 80,
          timeout: const Duration(milliseconds: 500));
      socket.destroy();

      String hostname = ip;
      try {
        final lookup = await InternetAddress.lookup(ip);
        if (lookup.isNotEmpty && lookup.first.host != ip) {
          hostname = lookup.first.host;
        }
      } catch (_) {}

      return NetworkDevice(ip: ip, mac: 'N/A', hostname: hostname);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ExposedPort>> checkPorts(
      NetworkDevice device, ScanType scanType) async {
    final portsToScan = scanType == ScanType.deep ? _deepPorts : _quickPorts;

    final futures = portsToScan.map((port) async {
      try {
        final socket = await Socket.connect(device.ip, port,
            timeout: const Duration(seconds: 2));
        socket.destroy();

        final service = _serviceMap[port] ?? 'Unknown';
        final risk = _highRisk.contains(port)
            ? RiskLevel.high
            : _mediumRisk.contains(port)
                ? RiskLevel.medium
                : RiskLevel.low;
        return ExposedPort(port: port, serviceType: service, riskLevel: risk);
      } catch (_) {
        return null;
      }
    }).toList();

    final results = await Future.wait(futures);
    return results.whereType<ExposedPort>().toList();
  }

  @override
  Future<AuditSession> runScan(String profileName, ScanType type) async {
    final subnet = await detectSubnet();
    final devices = await discoverDevices(subnet);
    final results = <DeviceWithPorts>[];

    const batchSize = 10;
    for (var i = 0; i < devices.length; i += batchSize) {
      final batch = devices.sublist(i, (i + batchSize).clamp(0, devices.length));
      final batchResults = await Future.wait(
        batch.map((device) async {
          final ports = await checkPorts(device, type);
          return DeviceWithPorts(device: device, ports: ports);
        }),
      );
      results.addAll(batchResults);
    }

    return AuditSession(
      id: DateTime.now().toIso8601String(),
      profileName: profileName,
      date: DateTime.now(),
      deviceCount: devices.length,
      scanType: type,
      devices: results,
    );
  }

  @override
  Future<List<AuditSession>> getHistory() async {
    return LocalStorage().loadSessions();
  }
}

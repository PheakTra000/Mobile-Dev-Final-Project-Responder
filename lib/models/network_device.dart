class NetworkDevice {
  final String ip;
  final String mac;
  final String hostname;
  final String deviceType;

  NetworkDevice({
    required this.ip,
    required this.mac,
    required this.hostname,
    this.deviceType = 'Unknown',
  });

  @override
  String toString() => 'NetworkDevice(ip: $ip, mac: $mac, hostname: $hostname, deviceType: $deviceType)';
}
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

  static NetworkDevice fromJson(Map<String, dynamic> json) {
    return NetworkDevice(
      ip: json['ip'] as String,
      mac: json['mac'] as String,
      hostname: json['hostname'] as String,
      deviceType: json['deviceType'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() => {
    'ip': ip,
    'mac': mac,
    'hostname': hostname,
    'deviceType': deviceType,
  };

  @override
  String toString() => 'NetworkDevice(ip: $ip, mac: $mac, hostname: $hostname, deviceType: $deviceType)';
}
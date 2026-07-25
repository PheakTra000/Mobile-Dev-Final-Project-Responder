class NetworkDevice {
  final String ip;
  final String mac;
  final String hostname;

  NetworkDevice({required this.ip, required this.mac, required this.hostname});

  static NetworkDevice fromJson(Map<String, dynamic> json) {
    assert(json['ip'] is String);
    assert(json['mac'] is String);
    assert(json['hostname'] is String);

    return NetworkDevice(
      ip: json['ip'],
      mac: json['mac'],
      hostname: json['hostname'],
    );
  }

  Map<String, dynamic> toJson() => {
    // convert NetworkDevice to json
    'ip': ip,
    'mac': mac,
    'hostname': hostname,
  };
}

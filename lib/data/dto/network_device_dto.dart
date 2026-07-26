import '../../models/network_device.dart';

class NetworkDeviceDto {
  static NetworkDevice fromJson(Map<String, dynamic> json) {
    return NetworkDevice(
      ip: json['ip'] as String,
      mac: json['mac'] as String,
      hostname: json['hostname'] as String,
    );
  }

  static Map<String, dynamic> toJson(NetworkDevice device) {
    return {
      'ip': device.ip,
      'mac': device.mac,
      'hostname': device.hostname,
    };
  }
}

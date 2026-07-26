import '../../models/device_with_ports.dart';
import 'network_device_dto.dart';
import 'exposed_port_dto.dart';

class DeviceWithPortsDto {
  static DeviceWithPorts fromJson(Map<String, dynamic> json) {
    return DeviceWithPorts(
      device: NetworkDeviceDto.fromJson(json['device'] as Map<String, dynamic>),
      ports: (json['ports'] as List)
          .map((p) => ExposedPortDto.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  static Map<String, dynamic> toJson(DeviceWithPorts dwp) {
    return {
      'device': NetworkDeviceDto.toJson(dwp.device),
      'ports': dwp.ports.map((p) => ExposedPortDto.toJson(p)).toList(),
    };
  }
}

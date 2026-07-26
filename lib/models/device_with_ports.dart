import 'network_device.dart';
import 'exposed_port.dart';

class DeviceWithPorts {
  final NetworkDevice device;
  final List<ExposedPort> ports;

  DeviceWithPorts({required this.device, required this.ports});
}

import 'device_with_ports.dart';

enum ScanType { quick, deep }

class AuditSession {
  final String id;
  final String profileName;
  final DateTime date;
  final int deviceCount;
  final ScanType scanType;
  final List<DeviceWithPorts>? devices;

  AuditSession({
    required this.id,
    required this.profileName,
    required this.date,
    required this.deviceCount,
    required this.scanType,
    this.devices,
  });
}

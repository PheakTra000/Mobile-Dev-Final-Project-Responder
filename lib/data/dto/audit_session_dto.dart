import '../../models/audit_session.dart';
import 'device_with_ports_dto.dart';

class AuditSessionDto {
  static AuditSession fromJson(Map<String, dynamic> json) {
    return AuditSession(
      id: json['id'] as String,
      profileName: json['profileName'] as String,
      date: DateTime.parse(json['date'] as String),
      deviceCount: json['deviceCount'] as int,
      scanType: json['scanType'] == 'Deep' ? ScanType.deep : ScanType.quick,
      devices: json['devices'] != null
          ? (json['devices'] as List)
              .map((d) => DeviceWithPortsDto.fromJson(d as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  static Map<String, dynamic> toJson(AuditSession session) {
    return {
      'id': session.id,
      'profileName': session.profileName,
      'date': session.date.toIso8601String(),
      'deviceCount': session.deviceCount,
      'scanType': session.scanType.name,
      'devices': session.devices?.map((d) => DeviceWithPortsDto.toJson(d)).toList(),
    };
  }
}

import '../../models/exposed_port.dart';

class ExposedPortDto {
  static ExposedPort fromJson(Map<String, dynamic> json) {
    return ExposedPort(
      port: json['port'] as int,
      serviceType: json['serviceType'] as String,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
      ),
    );
  }

  static Map<String, dynamic> toJson(ExposedPort port) {
    return {
      'port': port.port,
      'serviceType': port.serviceType,
      'riskLevel': port.riskLevel.name,
    };
  }
}

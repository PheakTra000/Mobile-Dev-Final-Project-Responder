enum RiskLevel { low, medium, high }

class ExposedPort {
  final int port;
  final String serviceType;
  final RiskLevel riskLevel;

  ExposedPort({
    required this.port,
    required this.serviceType,
    required this.riskLevel,
  });

  static ExposedPort fromJson(Map<String, dynamic> json) {
    final port = json['port'] as int;
    final serviceType = json['serviceType'] as String;
    final riskLevelStr = json['riskLevel'] as String;

    // Parse enum with a fallback to 'low' if unknown
    final riskLevel = RiskLevel.values.firstWhere(
      (e) => e.name == riskLevelStr,
      orElse: () => RiskLevel.low,
    );

    return ExposedPort(
      port: port,
      serviceType: serviceType,
      riskLevel: riskLevel,
    );
  }

  Map<String, dynamic> toJson() => {
    'port': port,
    'serviceType': serviceType,
    'riskLevel': riskLevel.name,
  };

  @override
  String toString() => 'ExposedPort(port: $port, serviceType: $serviceType, riskLevel: $riskLevel.name)';
}
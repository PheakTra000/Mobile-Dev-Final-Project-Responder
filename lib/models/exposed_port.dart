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
    assert(json['port'] is int);
    assert(json['serviceType'] is String);
    assert(json['riskLevel'] is String);

    RiskLevel level = RiskLevel.values.firstWhere(
      (e) => e.name == json['riskLevel'],
    );

    return ExposedPort(
      port: json['port'],
      serviceType: json['serviceType'],
      riskLevel: level,
    );
  }

  Map<String, dynamic> toJson() => {
    // convert ExposedPort to json
    'port': port,
    'serviceType': serviceType,
    'riskLevel': riskLevel.name,
  };
}

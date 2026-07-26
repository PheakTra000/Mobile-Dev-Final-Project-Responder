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

  @override
  String toString() => 'ExposedPort(port: $port, serviceType: $serviceType, riskLevel: $riskLevel.name)';
}
enum ScanType { quick, deep }

class AuditSession {
  final String id;
  final String profileName;
  final DateTime date;
  final int deviceCount;
  final ScanType scanType;

  AuditSession({
    required this.id,
    required this.profileName,
    required this.date,
    required this.deviceCount,
    required this.scanType,
  });

  // static method

  static AuditSession fromJson(Map<String, dynamic> json) {
    assert(json['id'] is String);
    assert(json['profileName'] is String);
    assert(json['date'] is String);
    assert(json['deviceCount'] is int);
    assert(json['ScanType'] is String);

    final date = DateTime.parse(json['date'] as String);

    ScanType type = ScanType.values.firstWhere(
      (e) => e.name == json['scanType'],
    );

    return AuditSession(
      id: json['id'],
      profileName: json['profileName'],
      date: date,
      deviceCount: json['deviceCount'],
      scanType: type,
    );
  }

  Map<String, dynamic> toJson() => {
    //convert AuditSession to json
    'id': id,
    'profileName': profileName,
    'DateTime': DateTime,
    'deviceCount': deviceCount,
    'ScanType': scanType.name,
  };
}

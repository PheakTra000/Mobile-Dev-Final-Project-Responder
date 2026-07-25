enum ScanType { quick, deep }

class AuditSession {
  final String id;
  final String profileName;
  final DateTime date;
  final int deviceCount;
  final ScanType scanType;
  final String ssid;
  final String bssid;
  final String subnetMask;

  AuditSession({
    required this.id,
    required this.profileName,
    required this.date,
    required this.deviceCount,
    required this.scanType,
    required this.ssid,
    required this.bssid,
    required this.subnetMask,
  });

  static AuditSession fromJson(Map<String, dynamic> json) {

    final id = json['id'] as String;
    final profileName = json['profileName'] as String;
    final dateStr = json['date'] as String;
    final deviceCount = json['deviceCount'] as int;
    final scanType = json['scanType'] as String;
    final ssid = json['ssid'] as String? ?? 'Unknown';
    final bssid = json['bssid'] as String? ?? 'Unknown';
    final subnetMask = json['subnetMask'] as String? ?? '255.255.255.0';

    final date = DateTime.parse(dateStr);
    final type = ScanType.values.firstWhere(
      (e) => e.name == scanType,
    );

    return AuditSession(
      id: id,
      profileName: profileName,
      date: date,
      deviceCount: deviceCount,
      scanType: type,
      ssid: ssid,
      bssid: bssid,
      subnetMask: subnetMask,
    );
  }

  Map<String, dynamic> toJson() => {

    'id': id,
    'profileName': profileName,
    'date': date.toIso8601String(),
    'deviceCount': deviceCount,
    'scanType': scanType.name,
    'ssid': ssid,
    'bssid': bssid,
    'subnetMask': subnetMask,
  };

  @override
  String toString() => 'AuditSession(id: $id, profile: $profileName, devices: $deviceCount, ssid: $ssid, bssid: $bssid, subnetMask: $subnetMask)';
}
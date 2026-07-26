import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/audit_session.dart';
import 'dto/audit_session_dto.dart';

class LocalStorage {
  Future<File> _sessionFile(String id) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/sessions/$id.json');
  }

  Future<void> saveSession(AuditSession session) async {
    final file = await _sessionFile(session.id);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(AuditSessionDto.toJson(session)));
  }

  Future<List<AuditSession>> loadSessions() async {
    final dir = await getApplicationDocumentsDirectory();
    final sessionsDir = Directory('${dir.path}/sessions');
    if (!await sessionsDir.exists()) return [];
    final files = await sessionsDir.list().where((e) => e is File).toList();
    final sessions = <AuditSession>[];
    for (final file in files) {
      try {
        final content = await (file as File).readAsString();
        sessions.add(AuditSessionDto.fromJson(jsonDecode(content)));
      } catch (_) {}
    }
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  Future<void> deleteSession(String id) async {
    final file = await _sessionFile(id);
    if (await file.exists()) await file.delete();
  }

  Future<void> renameSession(String id, String newProfileName) async {
    final file = await _sessionFile(id);
    if (!await file.exists()) return;
    final session =
        AuditSessionDto.fromJson(jsonDecode(await file.readAsString()));
    final updated = AuditSession(
      id: session.id,
      profileName: newProfileName,
      date: session.date,
      deviceCount: session.deviceCount,
      scanType: session.scanType,
      devices: session.devices,
    );
    await file.writeAsString(jsonEncode(AuditSessionDto.toJson(updated)));
  }
}

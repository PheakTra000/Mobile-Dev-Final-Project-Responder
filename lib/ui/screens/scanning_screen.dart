import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/api_client.dart';
import '../../data/local_storage.dart';
import '../../models/audit_session.dart';
import '../../models/device_with_ports.dart';
import '../../repositories/scan_repository.dart';
import '../widgets/device_card.dart';
import '../widgets/progress_indicator_widget.dart';

const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF9E9E9E);
const _error = Color(0xFFEF5350);

class ScanningScreen extends StatefulWidget {
  final String profileName;
  final ScanType scanType;
  final String? sessionId;

  const ScanningScreen({
    super.key,
    required this.profileName,
    required this.scanType,
    this.sessionId,
  });

  @override
  State<ScanningScreen> createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  double _progress = 0.0;
  String _status = 'Initializing...';
  List<DeviceWithPorts> _results = [];
  bool _isScanComplete = false;
  bool _hasError = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    const storage = FlutterSecureStorage();
    final uid = await storage.read(key: 'uid');
    if (!mounted) return;
    setState(() => _uid = uid);
    if (widget.sessionId != null) {
      _loadSessionDetail();
    } else {
      _startScan();
    }
  }

  LocalStorage get _ls => LocalStorage(userId: _uid);

  Future<void> _loadSessionDetail() async {
    setState(() {
      _status = 'Loading scan results...';
    });

    final sessions = await ApiClient.instance.fetchSessions();
    final session = sessions.firstWhere(
      (s) => s.id == widget.sessionId,
      orElse: () => AuditSession(
        id: '',
        profileName: '',
        date: DateTime.now(),
        deviceCount: 0,
        scanType: ScanType.quick,
      ),
    );

    setState(() {
      _results = session.devices ?? [];
      _progress = 1.0;
      _status = '${_results.length} devices found';
      _isScanComplete = true;
    });
  }

  Future<void> _startScan() async {
    try {
      final repo = ScanRepository();

      setState(() {
        _hasError = false;
        _progress = 0.05;
        _status = 'Detecting subnet...';
      });

      final subnet = await repo.detectSubnet();
      setState(() {
        _progress = 0.10;
        _status = 'Subnet: $subnet';
      });

      setState(() {
        _progress = 0.15;
        _status = 'Discovering devices...';
      });

      final devices = await repo.discoverDevices(subnet, onProgress: (p) {
        setState(() {
          _progress = 0.15 + p * 0.25;
        });
      });
      setState(() {
        _status = 'Found ${devices.length} devices';
      });

      if (devices.isEmpty) {
        await _saveSession([]);
        setState(() {
          _progress = 1.0;
          _status = 'No devices found';
          _isScanComplete = true;
        });
        return;
      }

      final List<DeviceWithPorts> results = [];
      const batchSize = 10;
      for (var i = 0; i < devices.length; i += batchSize) {
        final batchEnd = (i + batchSize).clamp(0, devices.length);
        final batch = devices.sublist(i, batchEnd);
        setState(() {
          _progress = 0.40 + (i / devices.length) * 0.55;
          _status = 'Scanning batch ${i ~/ batchSize + 1}...';
        });
        final batchResults = await Future.wait(
          batch.map((device) async {
            final ports = await repo.checkPorts(device, widget.scanType);
            return DeviceWithPorts(device: device, ports: ports);
          }),
        );
        results.addAll(batchResults);
      }

      await _saveSession(results);

      setState(() {
        _progress = 1.0;
        _status = '${results.length} devices found';
        _results = results;
        _isScanComplete = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Scan failed: ${e.toString()}';
        _isScanComplete = true;
        _hasError = true;
      });
    }
  }

  Future<void> _saveSession(List<DeviceWithPorts> results) async {
    final session = AuditSession(
      id: DateTime.now().toIso8601String(),
      profileName: widget.profileName,
      date: DateTime.now(),
      deviceCount: results.length,
      scanType: widget.scanType,
      devices: results,
    );

    await _ls.saveSession(session);

    try {
      const storage = FlutterSecureStorage();
      final jwt = await storage.read(key: 'jwt');
      if (jwt != null) {
        await ApiClient.instance.backupSession(session);
      }
    } catch (_) {}
  }

  void _onExportReportPressed() {
    final buffer = StringBuffer();
    buffer.writeln('=== Responder Scan Report ===');
    buffer.writeln('Profile: ${widget.profileName}');
    buffer.writeln('Date: ${DateTime.now()}');
    buffer.writeln('Scan Type: ${widget.scanType.name}');
    buffer.writeln('Devices Found: ${_results.length}');
    buffer.writeln();

    for (int i = 0; i < _results.length; i++) {
      final dwp = _results[i];
      buffer.writeln('--- Device ${i + 1}: ${dwp.device.hostname} ---');
      buffer.writeln('  IP: ${dwp.device.ip} | MAC: ${dwp.device.mac}');
      if (dwp.ports.isEmpty) {
        buffer.writeln('  No open ports');
      } else {
        buffer.writeln('  Open Ports:');
        for (final p in dwp.ports) {
          buffer.writeln('    ${p.port}/${p.serviceType} (${p.riskLevel.name} risk)');
        }
      }
      buffer.writeln();
    }

    Share.share(buffer.toString(), subject: 'Responder Scan Report');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder'),
        automaticallyImplyLeading: false,
      ),
      body: _isScanComplete ? _buildResults() : _buildProgress(),
    );
  }

  Widget _buildProgress() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          ScanProgressIndicator(
            progress: _progress,
            statusText: _status,
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: _error),
            const SizedBox(height: 16),
            Text(_status,
                style: const TextStyle(color: _textPrimary, fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isScanComplete = false;
                  _progress = 0.0;
                  _status = 'Initializing...';
                });
                _startScan();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.devices_other, size: 64, color: _textSecondary),
            const SizedBox(height: 16),
            Text(_status,
                style: const TextStyle(color: _textPrimary, fontSize: 18)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: ScanProgressIndicator(
            progress: _progress,
            statusText: _status,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text('${_results.length} devices',
                  style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton.icon(
                onPressed: _onExportReportPressed,
                icon: const Icon(Icons.file_download, size: 18),
                label: const Text('Export'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _results.length,
            itemBuilder: (context, index) {
              final dwp = _results[index];
              return DeviceCard(device: dwp.device, ports: dwp.ports);
            },
          ),
        ),
      ],
    );
  }
}

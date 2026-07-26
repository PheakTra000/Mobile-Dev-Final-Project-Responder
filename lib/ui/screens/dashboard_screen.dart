import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/async_data.dart';
import '../../data/local_storage.dart';
import '../../models/audit_session.dart';
import '../theme/app_theme.dart';
import '../widgets/history_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  AsyncData<List<AuditSession>> _sessions = AsyncData.notstarted();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _sessions = AsyncData.loading();
    });

    try {
      final sessions = await LocalStorage().loadSessions();
      if (!mounted) return;
      setState(() {
        _sessions = AsyncData.success(sessions);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sessions = AsyncData.error(e.toString());
      });
    }
  }

  void _showRenameDialog(AuditSession session) {
    final controller = TextEditingController(text: session.profileName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('Rename Scan', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'New name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await LocalStorage().renameSession(session.id, name);
                if (!mounted || !ctx.mounted) return;
                Navigator.pop(ctx);
                _loadHistory();
              }
            },
            child: Text('Rename', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(AuditSession session) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('Delete Scan', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Delete "${session.profileName}"? This cannot be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              await LocalStorage().deleteSession(session.id);
              if (!mounted || !ctx.mounted) return;
              Navigator.pop(ctx);
              _loadHistory();
            },
            child: Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 48),
            onSelected: (value) async {
              if (value == 'logout') {
                await const FlutterSecureStorage().deleteAll();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.error, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.card,
                child: Icon(Icons.person, color: AppTheme.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const _NetworkInfoCard(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/form').then((_) => _loadHistory()),
                  icon: const Icon(Icons.add),
                  label: const Text('Start New Scan'),
                ),
              ),
              const SizedBox(height: 28),
              Text('Scan History',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 16),
              _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return switch (_sessions.status) {
      AsyncStatus.notstarted => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Tap to refresh'),
        ),
      ),
      AsyncStatus.loading => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      ),
      AsyncStatus.error => Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_sessions.error ?? 'Unknown error', style: TextStyle(color: AppTheme.error)),
        ),
      ),
      AsyncStatus.success => _buildSessionList(),
    };
  }

  Widget _buildSessionList() {
    final sessions = _sessions.value ?? [];
    if (sessions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No scans yet'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return HistoryCard(
          session: session,
          onTap: () {
            Navigator.pushNamed(context, '/scanning', arguments: {
              'profileName': session.profileName,
              'scanType': session.scanType,
              'sessionId': session.id,
            }).then((_) => _loadHistory());
          },
          onRename: () => _showRenameDialog(session),
          onDelete: () => _showDeleteDialog(session),
        );
      },
    );
  }
}

class _NetworkInfoCard extends StatefulWidget {
  const _NetworkInfoCard();

  @override
  State<_NetworkInfoCard> createState() => _NetworkInfoCardState();
}

class _NetworkInfoCardState extends State<_NetworkInfoCard> {
  String _ssid = '--';
  String _gateway = '--';
  String _subnet = '--';

  static int _ipToInt(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
  }

  @override
  void initState() {
    super.initState();
    _loadNetworkInfo();
  }

  Future<void> _loadNetworkInfo() async {
    try {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        if (!mounted) return;
        setState(() {
          _ssid = 'Permission denied';
        });
        return;
      }

      final info = NetworkInfo();

      final ssid = await info.getWifiName();
      final gateway = await info.getWifiGatewayIP();
      final ip = await info.getWifiIP();

      int prefix = 24;
      if (ip != null) {
        try {
          final file = File('/proc/net/route');
          final lines = await file.readAsLines();
          int bestPrefix = 0;
          final wifiInt = _ipToInt(ip);
          for (final line in lines) {
            final parts = line.split('\t');
            if (parts.length < 8) continue;
            final destHex = int.parse(parts[1], radix: 16);
            final maskHex = int.parse(parts[7], radix: 16);
            if (maskHex == 0) continue;
            if ((wifiInt & maskHex) == (destHex & maskHex)) {
              int p = 0, m = maskHex;
              while (m != 0 && (m & 1) == 1) {
                p++;
                m >>= 1;
              }
              if (p > bestPrefix) bestPrefix = p;
            }
          }
          if (bestPrefix > 0) prefix = bestPrefix;
        } catch (_) {}
      }

      String subnet = '--';
      if (ip != null) {
        final ipBytes = ip.split('.').map(int.parse).toList();
        final maskInt = prefix == 0 ? 0 : (~0 << (32 - prefix)) & 0xFFFFFFFF;
        subnet =
            '${ipBytes[0] & ((maskInt >> 24) & 0xFF)}.${ipBytes[1] & ((maskInt >> 16) & 0xFF)}.${ipBytes[2] & ((maskInt >> 8) & 0xFF)}.${ipBytes[3] & (maskInt & 0xFF)}/$prefix';
      }

      if (!mounted) return;
      setState(() {
        _ssid = ssid ?? '--';
        _gateway = gateway ?? '--';
        _subnet = subnet;
      });
    } catch (_) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wifi, color: AppTheme.primary, size: 20),
              SizedBox(width: 8),
              Text('Current Network',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'SSID', value: _ssid),
          const SizedBox(height: 8),
          _InfoRow(label: 'Gateway', value: _gateway),
          const SizedBox(height: 8),
          _InfoRow(label: 'Subnet', value: _subnet),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: AppTheme.textSecondary, fontSize: 14)),
        Text(value,
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

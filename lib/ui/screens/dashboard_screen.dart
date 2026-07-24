import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _primary = Color(0xFF2AA9DF);
const _card = Color(0xFF1E1E1E);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF9E9E9E);
const _error = Color(0xFFEF5350);

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: _error, size: 20),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: _card,
                child: Icon(Icons.person, color: _primary),
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
                      Navigator.pushNamed(context, '/form'),
                  icon: const Icon(Icons.add),
                  label: const Text('Start New Scan'),
                ),
              ),
              const SizedBox(height: 28),
              const Text('Scan History',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No scans yet',
                      style: TextStyle(color: _textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkInfoCard extends StatelessWidget {
  const _NetworkInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wifi, color: _primary, size: 20),
              SizedBox(width: 8),
              Text('Current Network',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
          SizedBox(height: 12),
          _InfoRow(label: 'SSID', value: '--'),
          SizedBox(height: 8),
          _InfoRow(label: 'Gateway', value: '--'),
          SizedBox(height: 8),
          _InfoRow(label: 'Subnet', value: '--'),
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
            style: const TextStyle(
                color: _textSecondary, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: _textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

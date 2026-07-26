import 'package:flutter/material.dart';
import '../../models/network_device.dart';
import '../../models/exposed_port.dart';

const _primary = Color(0xFF2AA9DF);
const _card = Color(0xFF1E1E1E);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF9E9E9E);

class DeviceCard extends StatelessWidget {
  final NetworkDevice device;
  final List<ExposedPort> ports;

  const DeviceCard({
    super.key,
    required this.device,
    required this.ports,
  });

  Color _riskColor(RiskLevel level) {
    switch (level) {
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.devices, color: _primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.hostname,
                        style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text('${device.ip} | ${device.mac}',
                        style: const TextStyle(
                            color: _textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              if (ports.isNotEmpty)
                Text('${ports.length} ports',
                    style: const TextStyle(
                        color: _primary, fontSize: 12)),
            ],
          ),
          if (ports.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: ports.map((p) {
                final color = _riskColor(p.riskLevel);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${p.port}/${p.serviceType}',
                      style: TextStyle(color: color, fontSize: 11)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

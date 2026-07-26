import 'package:flutter/material.dart';
import '../../models/audit_session.dart';

const _card = Color(0xFF1E1E1E);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF9E9E9E);

class HistoryCard extends StatelessWidget {
  final AuditSession session;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const HistoryCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        '${session.date.month}/${session.date.day}/${session.date.year} at ${session.date.hour}:${session.date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.profileName,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(date,
                    style: const TextStyle(
                        color: _textSecondary, fontSize: 13)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: _textSecondary),
            onSelected: (value) {
              switch (value) {
                case 'view': onTap(); break;
                case 'rename': onRename(); break;
                case 'delete': onDelete(); break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'view', child: Text('View details')),
              const PopupMenuItem(value: 'rename', child: Text('Rename')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    );
  }
}

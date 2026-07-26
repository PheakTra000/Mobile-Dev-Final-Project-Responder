import 'package:flutter/material.dart';
import '../../models/audit_session.dart';

const _primary = Color(0xFF2AA9DF);
const _card = Color(0xFF1E1E1E);
const _textPrimary = Color(0xFFFFFFFF);
const _textSecondary = Color(0xFF9E9E9E);

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  ScanType _selectedType = ScanType.quick;
  final _nameController = TextEditingController(text: 'Untitled Scan');

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Configuration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text('Scan Title',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: _textPrimary),
              decoration: const InputDecoration(
                hintText: 'Enter a name for this scan',
              ),
            ),
            const SizedBox(height: 24),
            Text('Scan Type',
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _ScanOptionTile(
              title: 'Quick',
              description: 'Well known ports only, really fast.',
              isSelected: _selectedType == ScanType.quick,
              onTap: () => setState(() => _selectedType = ScanType.quick),
            ),
            const SizedBox(height: 12),
            _ScanOptionTile(
              title: 'Deep',
              description: 'Extended port range, slower but thorough.',
              isSelected: _selectedType == ScanType.deep,
              onTap: () => setState(() => _selectedType = ScanType.deep),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a scan title')),
                    );
                    return;
                  }
                  Navigator.pushNamed(context, '/scanning', arguments: {
                    'profileName': name,
                    'scanType': _selectedType.name,
                  });
                },
                child: const Text('Start New Scan'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ScanOptionTile extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _ScanOptionTile({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? _primary.withValues(alpha: 0.15)
              : _card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            _Radio(isSelected: isSelected),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(
                          color: _textSecondary, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool isSelected;

  const _Radio({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? _primary : Colors.grey,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _primary,
                ),
              ),
            )
          : null,
    );
  }
}

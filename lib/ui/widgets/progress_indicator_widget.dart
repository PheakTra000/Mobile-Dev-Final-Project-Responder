import 'package:flutter/material.dart';

const _primary = Color(0xFF2AA9DF);
const _textPrimary = Color(0xFFFFFFFF);

class ScanProgressIndicator extends StatelessWidget {
  final double progress;
  final String statusText;

  const ScanProgressIndicator({
    super.key,
    required this.progress,
    required this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  color: _primary,
                ),
              ),
              const Icon(
                Icons.shield_outlined,
                size: 48,
                color: _primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          statusText,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

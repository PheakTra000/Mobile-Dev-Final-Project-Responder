import 'package:flutter/material.dart';
import '../widgets/progress_indicator_widget.dart';

class ScanningScreen extends StatelessWidget {
  const ScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responder'),
        automaticallyImplyLeading: false,
      ),
      body: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(height: 32),
            ScanProgressIndicator(
              progress: null,
              statusText: 'Ready to scan',
            ),
          ],
        ),
      ),
    );
  }
}

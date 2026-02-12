import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeSection extends StatelessWidget {
  const QrCodeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: 'https://shuffleboard.snubbe.se',
              version: QrVersions.auto,
              size: 250,
            ),
            Text('shuffleboard.snubbe.se'),
          ],
        ),
      ),
    );
  }
}

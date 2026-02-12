import 'package:flutter/material.dart';
import 'package:shuffleboard_flutter/pages/landing/qr_code_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Center(child: QrCodeSection())),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: VerticalDivider(),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  'SPELA UTANFÖR TURNERING',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Expanded(
        //   child: Center(
        //     child: FilledButton(
        //       onPressed: () {},
        //       child: Text('Spela utan registrering'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
